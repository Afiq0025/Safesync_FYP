package com.fyp.safesync.safesync

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_NAME = "com.fyp.safesync.safesync/heartrate"
        var channel: MethodChannel? = null
        private const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize the MethodChannel
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        Log.d(TAG, "MethodChannel '$CHANNEL_NAME' initialized in MainActivity.")

        // Flush any buffered heart rate events
        if (HeartRateBuffer.pending.isNotEmpty()) {
            Log.d(TAG, "Flushing ${HeartRateBuffer.pending.size} buffered heart rate events.")
            HeartRateBuffer.pending.forEach { event ->
                channel?.invokeMethod("heartRateUpdate", event)
            }
            HeartRateBuffer.pending.clear()
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "MainActivity onDestroy: Clearing MethodChannel.")
        channel = null // Clean up the channel to avoid leaks
        super.onDestroy()
    }
}
