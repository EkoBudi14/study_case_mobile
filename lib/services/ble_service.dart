import 'dart:io' show Platform;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  bool get isScanningNow => FlutterBluePlus.isScanningNow;

  Future<void> startScan() {
    return FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: Duration(seconds: 10),
      androidScanMode: AndroidScanMode.lowLatency,
    );
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      final scanOk = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      final connectOk =
          statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      final locationOk =
          statuses[Permission.locationWhenInUse]?.isGranted ?? false;
      return scanOk && connectOk && locationOk;
    }
    if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }
    return true;
  }
}
