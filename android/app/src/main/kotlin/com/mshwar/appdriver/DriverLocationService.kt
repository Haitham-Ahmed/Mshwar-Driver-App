package com.mshwar.appdriver

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class DriverLocationService : Service() {
    companion object {
        const val ACTION_START = "com.mshwar.appdriver.START_LOCATION"
        const val ACTION_STOP = "com.mshwar.appdriver.STOP_LOCATION"
        private const val CHANNEL_ID = "mshwar_driver_location"
        private const val NOTIFICATION_ID = 4201
        private const val PREFS = "driver_location_service"
        private const val API_URL = "https://mshwar-app.com/api/v1/update-position"
        private const val TAG = "MshwarLocation"
    }

    private lateinit var fusedClient: FusedLocationProviderClient
    private var callback: LocationCallback? = null
    private var scheduler: ScheduledExecutorService? = null
    private val networkExecutor = Executors.newSingleThreadExecutor()
    @Volatile private var lastLocation: Location? = null
    @Volatile private var uploadInFlight = false
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopTracking()
            return START_NOT_STICKY
        }

        val prefs = getSharedPreferences(PREFS, MODE_PRIVATE)
        val driverId = intent?.getIntExtra("driverId", 0) ?: prefs.getInt("driverId", 0)
        val accessToken = intent?.getStringExtra("accessToken") ?: prefs.getString("accessToken", "").orEmpty()
        val apiKey = intent?.getStringExtra("apiKey") ?: prefs.getString("apiKey", "").orEmpty()
        if (driverId <= 0 || accessToken.isBlank() || apiKey.isBlank()) {
            Log.w(TAG, "Tracking not started: missing driver credentials")
            stopSelf()
            return START_NOT_STICKY
        }

        prefs.edit()
            .putBoolean("online", true)
            .putInt("driverId", driverId)
            .putString("accessToken", accessToken)
            .putString("apiKey", apiKey)
            .apply()

        startForeground(NOTIFICATION_ID, buildNotification())
        startTracking()
        return START_STICKY
    }

    private fun startTracking() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
            ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            Log.w(TAG, "Tracking not started: location permission missing")
            stopSelf()
            return
        }
        if (callback != null) return

        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "$packageName:driver-location").apply {
            setReferenceCounted(false)
            acquire()
        }

        val request = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 15_000L)
            .setMinUpdateIntervalMillis(10_000L)
            .setMaxUpdateDelayMillis(15_000L)
            .setMinUpdateDistanceMeters(0f)
            .build()
        callback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                result.lastLocation?.let {
                    lastLocation = it
                    upload(it)
                }
            }
        }
        fusedClient.requestLocationUpdates(request, callback!!, Looper.getMainLooper())
        fusedClient.lastLocation.addOnSuccessListener { location ->
            location?.let {
                lastLocation = it
                upload(it)
            }
        }
        scheduler = Executors.newSingleThreadScheduledExecutor().also { executor ->
            executor.scheduleAtFixedRate({ lastLocation?.let(::upload) }, 15, 15, TimeUnit.SECONDS)
        }
        Log.i(TAG, "Foreground driver location tracking started")
    }

    private fun upload(location: Location) {
        if (uploadInFlight) return
        uploadInFlight = true
        networkExecutor.execute {
            try {
                val prefs = getSharedPreferences(PREFS, MODE_PRIVATE)
                if (!prefs.getBoolean("online", false)) return@execute
                val body = JSONObject()
                    .put("id_user", prefs.getInt("driverId", 0))
                    .put("user_cat", "driver")
                    .put("latitude", location.latitude.toString())
                    .put("longitude", location.longitude.toString())
                val connection = (URL(API_URL).openConnection() as HttpURLConnection).apply {
                    requestMethod = "POST"
                    connectTimeout = 10_000
                    readTimeout = 10_000
                    doOutput = true
                    setRequestProperty("Content-Type", "application/json; charset=UTF-8")
                    setRequestProperty("apikey", prefs.getString("apiKey", ""))
                    setRequestProperty("accesstoken", prefs.getString("accessToken", ""))
                }
                connection.outputStream.use { it.write(body.toString().toByteArray(Charsets.UTF_8)) }
                val status = connection.responseCode
                if (status in 200..299) {
                    prefs.edit().putLong("lastSuccessfulUpload", System.currentTimeMillis()).apply()
                    Log.i(TAG, "Location uploaded successfully ($status)")
                } else {
                    Log.w(TAG, "Location upload failed ($status)")
                }
                connection.disconnect()
            } catch (e: Exception) {
                Log.w(TAG, "Location upload will retry on next heartbeat", e)
            } finally {
                uploadInFlight = false
            }
        }
    }

    private fun stopTracking() {
        getSharedPreferences(PREFS, MODE_PRIVATE).edit().putBoolean("online", false).apply()
        callback?.let { fusedClient.removeLocationUpdates(it) }
        callback = null
        scheduler?.shutdownNow()
        scheduler = null
        if (wakeLock?.isHeld == true) wakeLock?.release()
        wakeLock = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        Log.i(TAG, "Foreground driver location tracking stopped")
    }

    override fun onDestroy() {
        callback?.let { fusedClient.removeLocationUpdates(it) }
        scheduler?.shutdownNow()
        if (wakeLock?.isHeld == true) wakeLock?.release()
        networkExecutor.shutdown()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Driver location sharing",
                NotificationManager.IMPORTANCE_LOW
            ).apply { description = "Shown while an online driver shares location" }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification() = NotificationCompat.Builder(this, CHANNEL_ID)
        .setSmallIcon(R.mipmap.ic_launcher)
        .setContentTitle("Mshwar Captain is online")
        .setContentText("Your location is being shared for ride dispatch")
        .setOngoing(true)
        .setOnlyAlertOnce(true)
        .setCategory(NotificationCompat.CATEGORY_SERVICE)
        .setContentIntent(
            PendingIntent.getActivity(
                this,
                0,
                packageManager.getLaunchIntentForPackage(packageName),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        )
        .build()
}
