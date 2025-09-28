import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  bool get isConnected => _connection != null && _connection!.isConnected;

  String bpm = "0";
  String steps = "0";
  String rawData = "";

  Future<void> connect(BluetoothDevice device) async {
    if (isConnected) return;

    _connection = await BluetoothConnection.toAddress(device.address);
    _connection!.input!.listen((Uint8List data) {
      String msg = String.fromCharCodes(data).trim();
      rawData += msg + "\n";

      if (msg.contains("BPM=") && msg.contains("Steps=")) {
        final parts = msg.split(' ');
        bpm = parts[1].split('=')[1];
        steps = parts[3].split('=')[1];
      }
    }).onDone(() {
      disconnect();
    });
  }

  void disconnect() {
    _connection?.dispose();
    _connection = null;
  }
}