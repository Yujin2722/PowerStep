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
  String battery = "0";

  Future<void> connect(BluetoothDevice device) async {
    if (isConnected) return;

    _connection = await BluetoothConnection.toAddress(device.address);
    _connection!.input!
        .listen((Uint8List data) {
          String msg = String.fromCharCodes(data).trim();
          rawData += msg + "\n";

          if (msg.contains("BPM=")) {
            final match = RegExp(r"BPM=([\d.]+)").firstMatch(msg);
            if (match != null) bpm = match.group(1)!;
          }

          if (msg.contains("Steps=")) {
            final match = RegExp(r"Steps=(\d+)").firstMatch(msg);
            if (match != null) steps = match.group(1)!;
          }

          if (msg.contains("BAT=")) {
            final match = RegExp(r"BAT=(\d+)%").firstMatch(msg);
            if (match != null) battery = match.group(1)!;
          }
        })
        .onDone(() {
          disconnect();
        });
  }

  void disconnect() {
    _connection?.dispose();
    _connection = null;
  }
}
