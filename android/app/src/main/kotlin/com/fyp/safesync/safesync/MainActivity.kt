package com.fyp.safesync.safesync

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var permissionResult: MethodChannel.Result? = null
    private val bluetoothPermissionRequestCode = 1

    companion object {
        private const val HEARTRATE_CHANNEL = "com.fyp.safesync.safesync/heartrate"
        var channel: MethodChannel? = null
        private const val TAG = "MainActivity"
        private const val BLUETOOTH_CHANNEL = "com.fyp.safesync.safesync/bluetooth"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (intent.getBooleanExtra("from_background", false)) {
            moveTaskToBack(true)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEARTRATE_CHANNEL)
        Log.d(TAG, "MethodChannel '$HEARTRATE_CHANNEL' initialized in MainActivity.")

        if (HeartRateBuffer.pending.isNotEmpty()) {
            Log.d(TAG, "Flushing ${HeartRateBuffer.pending.size} buffered heart rate events.")
            HeartRateBuffer.pending.forEach { event ->
                channel?.invokeMethod("heartRateUpdate", event)
            }
            HeartRateBuffer.pending.clear()
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestBluetoothConnectPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        if (checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                            permissionResult = result
                            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.BLUETOOTH_CONNECT), bluetoothPermissionRequestCode)
                        } else {
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }
                "isBluetoothEnabled" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                        checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                        result.error("PERMISSION_DENIED", "BLUETOOTH_CONNECT permission not granted.", null)
                    } else {
                        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                        result.success(bluetoothAdapter?.isEnabled == true)
                    }
                }
                "requestBluetooth" -> {
                    val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                    if (bluetoothAdapter?.isEnabled == false) {
                        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                        startActivityForResult(enableBtIntent, 1)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "openBluetoothSettings" -> {
                    val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == bluetoothPermissionRequestCode) {
            val isGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            permissionResult?.success(isGranted)
            permissionResult = null
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "MainActivity onDestroy: Clearing MethodChannel.")
        channel = null
        super.onDestroy()
    }
}
