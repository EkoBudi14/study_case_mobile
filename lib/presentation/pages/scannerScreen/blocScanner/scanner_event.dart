part of 'scanner_bloc.dart';

class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerStartPressed extends ScannerEvent {}

class ScannerStopPressed extends ScannerEvent {}

class ScannerResultsUpdated extends ScannerEvent {
  final List<BleDeviceModel> devices;
  const ScannerResultsUpdated(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ScannerBluetoothChanged extends ScannerEvent {
  final bool isOn;
  const ScannerBluetoothChanged(this.isOn);

  @override
  List<Object?> get props => [isOn];
}

class ScannerScanningChanged extends ScannerEvent {
  final bool isScanning;
  const ScannerScanningChanged(this.isScanning);

  @override
  List<Object?> get props => [isScanning];
}

class ScannerSearchChanged extends ScannerEvent {
  final String query;
  const ScannerSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ScannerMinRssiChanged extends ScannerEvent {
  final int minRssi;
  const ScannerMinRssiChanged(this.minRssi);

  @override
  List<Object?> get props => [minRssi];
}
