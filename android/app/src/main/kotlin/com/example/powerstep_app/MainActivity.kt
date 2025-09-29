package com.example.powerstep_app

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.powerstep_app/bluetooth"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger!!, CHANNEL)
        .setMethodCallHandler { call, result ->
            if (call.method == "getBondedDevices") {
                val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
                if (bluetoothAdapter == null) {
                    result.error("UNAVAILABLE", "Bluetooth not supported", null)
                    return@setMethodCallHandler
                }

                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                    // Android 12+ (SDK 31+)
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT)
                        != PackageManager.PERMISSION_GRANTED
                    ) {
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
                            1001
                        )
                        return@setMethodCallHandler
                    }
                } else {
                    // Android 11 (SDK 30) or lower
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED
                    ) {
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                            1001
                        )
                        return@setMethodCallHandler
                    }
                }

                // ✅ Safe bonded devices fetch
                val bondedDevices = bluetoothAdapter.bondedDevices.map { device ->
                    mapOf(
                        "name" to device.name,
                        "address" to device.address
                    )
                }

                result.success(bondedDevices)
            } else {
                result.notImplemented()
            }
        }
    }

    // ⬇️ Place this OUTSIDE configureFlutterEngine but INSIDE MainActivity
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == 1001 &&
            grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        ) {
            val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
            val bondedDevices = bluetoothAdapter?.bondedDevices?.map { device ->
                mapOf("name" to device.name, "address" to device.address)
            } ?: emptyList()

            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onBondedDevices", bondedDevices)
        }
    }
}