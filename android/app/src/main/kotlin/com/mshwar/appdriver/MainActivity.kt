package com.mshwar.appdriver

import android.Manifest
import android.content.Intent
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.mshwar.appdriver/location_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                9001
                            )
                        }
                        val intent = Intent(this, DriverLocationService::class.java).apply {
                            action = DriverLocationService.ACTION_START
                            putExtra("driverId", call.argument<Int>("driverId") ?: 0)
                            putExtra("accessToken", call.argument<String>("accessToken") ?: "")
                            putExtra("apiKey", call.argument<String>("apiKey") ?: "")
                        }
                        ContextCompat.startForegroundService(this, intent)
                        result.success(true)
                    }
                    "stop" -> {
                        val intent = Intent(this, DriverLocationService::class.java).apply {
                            action = DriverLocationService.ACTION_STOP
                        }
                        startService(intent)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
