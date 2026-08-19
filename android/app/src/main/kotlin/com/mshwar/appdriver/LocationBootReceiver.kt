package com.mshwar.appdriver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class LocationBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prefs = context.getSharedPreferences("driver_location_service", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("online", false)) return
        val serviceIntent = Intent(context, DriverLocationService::class.java).apply {
            action = DriverLocationService.ACTION_START
        }
        ContextCompat.startForegroundService(context, serviceIntent)
    }
}
