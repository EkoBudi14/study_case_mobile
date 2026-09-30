import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../../data/sources/model/bleDeviceModel.dart';

abstract class BleRepository {
  Future<Either<Failure, bool>> isSupported();

  Future<Either<Failure, bool>> requestPermissions();

  Future<Either<Failure, bool>> startScan();

  Future<Either<Failure, bool>> stopScan();

  Stream<bool> bluetoothOn();

  Stream<List<BleDeviceModel>> scanResults();

  Stream<bool> scanningState();

  bool get isScanningNow;
}
