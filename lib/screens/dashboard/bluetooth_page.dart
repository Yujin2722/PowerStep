// bluetooth_hc05.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '/services/bluetooth_service.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class BluetoothHC05Page extends StatefulWidget {
  const BluetoothHC05Page({super.key});

  @override
  State<BluetoothHC05Page> createState() => _BluetoothHC05PageState();
}

const platform = MethodChannel('com.example.powerstep_app/bluetooth');
final BluetoothService _bluetoothService = BluetoothService();

class _BluetoothHC05PageState extends State<BluetoothHC05Page> {
  List<BluetoothDevice> _bondedDevices = [];
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _initBluetooth();

    platform.setMethodCallHandler((call) async {
      if (call.method == "onBondedDevices") {
        final List devices = call.arguments as List;
        setState(() {
          _bondedDevices = devices
              .map(
                (d) => BluetoothDevice(
                  name: d['name'],
                  address: d['address'],
                  type: BluetoothDeviceType.classic,
                ),
              )
              .toList()
              .cast<BluetoothDevice>();
        });
        print("📡 Updated bonded devices: $_bondedDevices");
      }
      return null;
    });
  }

  Future<void> _initBluetooth() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    bool granted = false;

    if (Platform.isAndroid) {
      if (sdkInt >= 31) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.nearbyWifiDevices,
        ].request();

        granted = statuses.values.every((status) => status.isGranted);
      } else {
        final statuses = await [
          Permission.location,
          Permission.bluetooth,
        ].request();

        granted = statuses.values.every((status) => status.isGranted);
      }
    }

    if (!granted) {
      print("❌ Permissions not granted");
      return;
    }

    try {
      final List devices = await platform.invokeMethod('getBondedDevices');
      setState(() {
        _bondedDevices = devices
            .map(
              (d) => BluetoothDevice(
                name: d['name'],
                address: d['address'],
                type: BluetoothDeviceType.classic,
              ),
            )
            .toList()
            .cast<BluetoothDevice>();
      });

      print("✅ Found bonded devices: $_bondedDevices");
    } on PlatformException catch (e) {
      print("Failed to get bonded devices: ${e.message}");
    }
  }

  void _connectToDevice() async {
    if (_selectedDevice == null) return;
    try {
      await _bluetoothService.connect(_selectedDevice!);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canConnect =
        !_bluetoothService.isConnected && _selectedDevice != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 233, 119),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Connect to Bluetooth",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _initBluetooth,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo_green.png',
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "How to connect",
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Step 1
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: '1. On your phone, open '),
                            TextSpan(
                              text: 'Settings',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ', go to '),
                            TextSpan(
                              text: 'Bluetooth',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ', and make sure Bluetooth is ',
                            ),
                            TextSpan(
                              text: 'ON',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Step 2
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: '2. '),
                            TextSpan(
                              text: 'Pair with HC-05',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' from the Bluetooth settings. When prompted, enter the ',
                            ),
                            TextSpan(
                              text: 'PIN 1234',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' (sometimes 0000).'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Step 3
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: '3. Open the '),
                            TextSpan(
                              text: 'PowerStep',
                              style: TextStyle(
                                fontFamily: 'BukhariScript',
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const TextSpan(text: ' app.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Step 4
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: '4. '),
                            TextSpan(
                              text: 'Select HC-05',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ' from the device list and press ',
                            ),
                            TextSpan(
                              text: 'Connect Device',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<BluetoothDevice>(
                                  isExpanded: true,
                                  hint: Text(
                                    _bondedDevices.isEmpty
                                        ? "No paired devices"
                                        : "Select a device",
                                    style: GoogleFonts.manrope(fontSize: 15),
                                  ),
                                  value: _selectedDevice,
                                  items: _bondedDevices
                                      .map(
                                        (device) => DropdownMenuItem(
                                          value: device,
                                          child: Text(
                                            device.name ?? device.address,
                                            style: GoogleFonts.manrope(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (device) {
                                    setState(() => _selectedDevice = device);
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            onPressed: canConnect ? _connectToDevice : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canConnect
                                  ? const Color.fromARGB(255, 0, 233, 119)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _bluetoothService.isConnected
                                  ? "Connected"
                                  : "Connect",
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Step 5 and 6
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                              text: '5. Wait until the app shows ',
                            ),
                            TextSpan(
                              text: 'Connected',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                              text: '6. You can now use PowerStep. ',
                            ),
                            TextSpan(
                              text: 'Enjoy',
                              style: GoogleFonts.manrope(
                                color: Color.fromARGB(255, 0, 233, 119),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '!'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // commented out kase only for debugging
              // Raw logs
              //Expanded(
              //child: SingleChildScrollView(
              //child: Text(
              //_bluetoothService.rawData,
              //style: GoogleFonts.manrope(fontSize: 14),
              //),
              //),
              //),
            ],
          ),
        ),
      ),
    );
  }
}
