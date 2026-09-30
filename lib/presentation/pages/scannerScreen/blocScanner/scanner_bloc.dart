import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/sources/model/bleDeviceModel.dart';
import '../../../../domain/usecase/getBluetoothState.dart';
import '../../../../domain/usecase/getScanResults.dart';
import '../../../../domain/usecase/getScanningState.dart';
import '../../../../domain/usecase/isSupported.dart';
import '../../../../domain/usecase/requestPermissions.dart';
import '../../../../domain/usecase/saveDevice.dart';
import '../../../../domain/usecase/startScan.dart';
import '../../../../domain/usecase/stopScan.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final IsSupported isSupported;
  final RequestPermissions requestPermissions;
  final GetBluetoothState getBluetoothState;
  final GetScanResults getScanResults;
  final GetScanningState getScanningState;
  final StartScan startScan;
  final StopScan stopScan;
  final SaveDevice saveDevice;

  List<BleDeviceModel> _devices = [];
  String _search = '';
  int _minRssi = -100;
  bool _bluetoothOn = false;
  bool _bluetoothKnown = false;
  bool _isScanning = false;

  bool _live = false;
  String? _error;

  final Map<String, DateTime> _lastPersist = {};

  StreamSubscription<List<BleDeviceModel>>? _resultsSub;
  StreamSubscription<bool>? _bluetoothSub;
  StreamSubscription<bool>? _scanningSub;

  ScannerBloc({
    required this.isSupported,
    required this.requestPermissions,
    required this.getBluetoothState,
    required this.getScanResults,
    required this.getScanningState,
    required this.startScan,
    required this.stopScan,
    required this.saveDevice,
  }) : super(ScannerInitial()) {
    on<ScannerStartPressed>(_onStartPressed);
    on<ScannerStopPressed>(_onStopPressed);
    on<ScannerResultsUpdated>(_onResultsUpdated);
    on<ScannerBluetoothChanged>(_onBluetoothChanged);
    on<ScannerScanningChanged>(_onScanningChanged);
    on<ScannerSearchChanged>(_onSearchChanged);
    on<ScannerMinRssiChanged>(_onMinRssiChanged);

    _resultsSub = getScanResults.execute().listen(
      (devices) => add(ScannerResultsUpdated(devices)),
    );
    _bluetoothSub = getBluetoothState.execute().listen(
      (isOn) => add(ScannerBluetoothChanged(isOn)),
    );

    _scanningSub = getScanningState.execute().listen(
      (scanning) => add(ScannerScanningChanged(scanning)),
    );
  }

  void _emit(Emitter<ScannerState> emit) {
    emit(
      ScannerUpdated(
        devices: _devices,
        search: _search,
        minRssi: _minRssi,
        bluetoothOn: _bluetoothOn,
        bluetoothKnown: _bluetoothKnown,

        isScanning: _live,
        errorMessage: _error,
      ),
    );
  }

  Future<void> _onStartPressed(
    ScannerStartPressed event,
    Emitter<ScannerState> emit,
  ) async {
    _error = null;

    final supRes = await isSupported.execute();
    if (supRes.isLeft() || !supRes.getOrElse(() => false)) {
      _error = 'Perangkat ini tidak mendukung Bluetooth LE.';
      _emit(emit);
      return;
    }

    final permRes = await requestPermissions.execute();
    if (permRes.isLeft() || !permRes.getOrElse(() => false)) {
      _error = 'Izin Bluetooth/Lokasi ditolak. Berikan izin di Pengaturan.';
      _emit(emit);
      return;
    }

    if (!_bluetoothOn) {
      _error = 'Bluetooth mati. Aktifkan Bluetooth lalu coba lagi.';
      _emit(emit);
      return;
    }

    final startRes = await startScan.execute();
    startRes.fold(
      (failure) => _error = 'Gagal memulai pemindaian: ${failure.message}',
      (_) {
        _error = null;
        _live = true;
      },
    );
    _emit(emit);
  }

  Future<void> _onStopPressed(
    ScannerStopPressed event,
    Emitter<ScannerState> emit,
  ) async {
    _live = false;
    await stopScan.execute();
    _emit(emit);
  }

  void _onResultsUpdated(
    ScannerResultsUpdated event,
    Emitter<ScannerState> emit,
  ) {
    if (!_live) return;
    _devices = event.devices;
    _persistThrottled(event.devices);
    _emit(emit);
  }

  void _onBluetoothChanged(
    ScannerBluetoothChanged event,
    Emitter<ScannerState> emit,
  ) {
    _bluetoothOn = event.isOn;
    _bluetoothKnown = true;
    if (!event.isOn && _isScanning) {
      _error = 'Bluetooth dimatikan. Aktifkan untuk melanjutkan.';
    }
    _emit(emit);
  }

  void _onScanningChanged(
    ScannerScanningChanged event,
    Emitter<ScannerState> emit,
  ) {
    _isScanning = event.isScanning;
    _emit(emit);
  }

  void _onSearchChanged(
    ScannerSearchChanged event,
    Emitter<ScannerState> emit,
  ) {
    _search = event.query;
    _emit(emit);
  }

  void _onMinRssiChanged(
    ScannerMinRssiChanged event,
    Emitter<ScannerState> emit,
  ) {
    _minRssi = event.minRssi;
    _emit(emit);
  }

  void _persistThrottled(List<BleDeviceModel> devices) {
    final now = DateTime.now();
    for (final d in devices) {
      final last = _lastPersist[d.id];
      if (last == null || now.difference(last).inSeconds >= 3) {
        _lastPersist[d.id] = now;
        saveDevice.execute(d);
      }
    }
  }

  @override
  Future<void> close() {
    _resultsSub?.cancel();
    _bluetoothSub?.cancel();
    _scanningSub?.cancel();
    return super.close();
  }
}
