package com.example.restaurant_app

import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    private val SETTINGS_CHANNEL = "com.example.restaurant_app/settings"
    private val TIMEZONE_CHANNEL = "com.example.restaurant_app/timezone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Settings channel for alarm settings
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openAlarmSettings") {
                try {
                    val intent = Intent()
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        intent.action = Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
                    } else {
                        intent.action = Settings.ACTION_SETTINGS
                    }
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Could not open settings", null)
                }
            } else {
                result.notImplemented()
            }
        }
        
        // Timezone channel to get device timezone
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMEZONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getTimeZone") {
                try {
                    val timeZone = TimeZone.getDefault().id
                    result.success(timeZone)
                } catch (e: Exception) {
                    result.error("TIMEZONE_ERROR", "Failed to get timezone", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
