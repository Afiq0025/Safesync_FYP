package com.fyp.safesync.safesync

import android.util.Log
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService
import android.os.Handler
import android.os.Looper

// Buffer heart rate / battery data if Flutter isn't ready yet
object HeartRateBuffer {
    val pending = mutableListOf<Map<String, Any>>()
}

class DataLayerListenerService : WearableListenerService() {

    private val TAG = "DataLayerService"

    override fun onCreate() {
        super.onCreate()
        Log.e("PHONE_RECEIVE_DEBUG", "!!!! DataLayerListenerService CREATED !!!!")
    }

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.e("PHONE_RECEIVE_DEBUG", "!!!! onDataChanged triggered with ${dataEvents.count} events !!!!")

        dataEvents.forEach { event ->
            Log.e("PHONE_RECEIVE_DEBUG", "Event TYPE=${event.type}, PATH=${event.dataItem.uri.path}")

            if (event.type == DataEvent.TYPE_CHANGED) {
                val dataItem = event.dataItem
                val path = dataItem.uri.path ?: ""
                try {
                    val dataMap = DataMapItem.fromDataItem(dataItem).dataMap
                    when {
                        path.equals("/heartRate", ignoreCase = true) -> {
                            val bpm = dataMap.getInt("bpm")
                            val timestamp = dataMap.getLong("timestamp")
                            Log.e(TAG, "Received BPM from watch: $bpm, Timestamp: $timestamp")

                            val heartRateData = mapOf("bpm" to bpm, "timestamp" to timestamp)

                            Handler(Looper.getMainLooper()).post {
                                MainActivity.channel?.let {
                                    Log.e(TAG, "SUCCESS: Sending BPM to Flutter via MethodChannel")
                                    it.invokeMethod("heartRateUpdate", heartRateData)
                                } ?: run {
                                    Log.w(TAG, "MethodChannel not ready. Buffering heart rate data.")
                                    HeartRateBuffer.pending.add(heartRateData)
                                }
                            }
                        }
                        path.equals("/batteryLevel", ignoreCase = true) -> {
                            val battery = dataMap.getInt("battery")
                            val timestamp = dataMap.getLong("timestamp")
                            Log.e(TAG, "Received Battery from watch: $battery%, Timestamp: $timestamp")

                            val batteryData = mapOf("battery" to battery, "timestamp" to timestamp)

                            Handler(Looper.getMainLooper()).post {
                                MainActivity.channel?.let {
                                    Log.e(TAG, "SUCCESS: Sending Battery to Flutter via MethodChannel")
                                    it.invokeMethod("batteryUpdate", batteryData)
                                } ?: run {
                                    Log.w(TAG, "MethodChannel not ready. Buffering battery data.")
                                    HeartRateBuffer.pending.add(batteryData)
                                }
                            }
                        }
                        else -> {
                            Log.w(TAG, "Received data item with UNEXPECTED PATH: $path")
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error processing data item: ${dataItem.uri}", e)
                }
            } else if (event.type == DataEvent.TYPE_DELETED) {
                Log.w(TAG, "Received DELETED data event: ${event.dataItem.uri}")
            }
        }

        dataEvents.release()
        super.onDataChanged(dataEvents)
    }

    override fun onDestroy() {
        Log.d(TAG, "DataLayerListenerService destroyed.")
        super.onDestroy()
    }
}