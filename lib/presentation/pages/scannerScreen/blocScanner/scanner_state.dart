part of 'scanner_bloc.dart';

class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerUpdated extends ScannerState {
  final List<BleDeviceModel> devices;
  final String search;
  final int minRssi;
  final bool bluetoothOn;
  final bool bluetoothKnown;
  final bool isScanning;
  final String? errorMessage;

  const ScannerUpdated({
    required this.devices,
    required this.search,
    required this.minRssi,
    required this.bluetoothOn,
    required this.bluetoothKnown,
    required this.isScanning,
    this.errorMessage,
  });

  List<BleDeviceModel> get visibleDevices {
    final query = search.trim().toLowerCase();
    final filtered = devices.where((d) {
      final matchesQuery =
          query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.id.toLowerCase().contains(query);
      return matchesQuery && d.rssi >= minRssi;
    }).toList();
    filtered.sort((a, b) => b.rssi.compareTo(a.rssi));
    return filtered;
  }

  @override
  List<Object?> get props => [
    devices,
    search,
    minRssi,
    bluetoothOn,
    bluetoothKnown,
    isScanning,
    errorMessage,
  ];
}
