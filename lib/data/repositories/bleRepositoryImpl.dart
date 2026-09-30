import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';

import '../../common/failure.dart';
import '../../common/helperText.dart';
import '../../domain/repositories/bleRepository.dart';
import '../../services/ble_service.dart';
import '../sources/model/bleDeviceModel.dart';

class BleRepositoryImpl implements BleRepository {
  final BleService _service = GetIt.instance.get<BleService>();

  @override
  Future<Either<Failure, bool>> isSupported() async {
    try {
      return Right(await _service.isSupported);
    } catch (e) {
      return Left(ServerFailure(NOT_SUPPORTED, additionalData: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final granted = await _service.requestPermissions();
      if (!granted) return Left(PermissionFailure(PERMISSION_DENIED));
      return Right(true);
    } catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> startScan() async {
    try {
      await _service.startScan();
      return Right(true);
    } catch (e) {
      return Left(ServerFailure(SCAN_FAILED, additionalData: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> stopScan() async {
    try {
      await _service.stopScan();
      return Right(true);
    } catch (e) {
      return Left(ServerFailure(SCAN_FAILED, additionalData: e.toString()));
    }
  }

  @override
  Stream<bool> bluetoothOn() {
    return _service.adapterState.map(
      (state) => state == BluetoothAdapterState.on,
    );
  }

  @override
  Stream<List<BleDeviceModel>> scanResults() {
    return _service.scanResults.map((results) {
      final now = DateTime.now();

      return results
          .map(
            (r) => BleDeviceModel(
              id: r.device.remoteId.str,
              name: _resolveName(r),
              rssi: r.rssi,
              lastSeen: now,
            ),
          )
          .toList();
    });
  }

  @override
  Stream<bool> scanningState() => _service.isScanning;

  @override
  bool get isScanningNow => _service.isScanningNow;

  String _resolveName(ScanResult r) {
    // 1) Name from the device (needs connection/cache) or the advertisement.
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    if (r.advertisementData.advName.isNotEmpty) {
      return r.advertisementData.advName;
    }
    // 2) Many devices advertise no name, so guess the maker from the
    //    manufacturer data company id.
    final manufacturer = _manufacturerName(
      r.advertisementData.manufacturerData,
    );
    if (manufacturer != null) return 'Perangkat $manufacturer';
    // 3) Last resort: show the tail of the MAC/UUID so rows stay distinct.
    final id = r.device.remoteId.str;
    final shortId = id.length >= 5 ? id.substring(id.length - 5) : id;
    return 'Perangkat $shortId';
  }

  String? _manufacturerName(Map<int, List<int>> manufacturerData) {
    if (manufacturerData.isEmpty) return null;
    // Company ids assigned by the Bluetooth SIG. Written in hex, Dart reads
    // them as decimal (0x004C == 76). Full list: assigned_numbers/company_identifiers.
    const companies = <int, String>{
      0x004C: 'Apple',
      0x0075: 'Samsung',
      0x0006: 'Microsoft',
      0x00E0: 'Google',
      0x038F: 'Xiaomi',
      0x012D: 'Sony',
      0x0087: 'Garmin',
      0x0059: 'Nordic',
      0x0002: 'Intel',
    };
    final id = manufacturerData.keys.first;
    return companies[id];
  }
}
