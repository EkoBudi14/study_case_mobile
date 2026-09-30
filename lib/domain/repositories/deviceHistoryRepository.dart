import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../../data/sources/model/bleDeviceModel.dart';

abstract class DeviceHistoryRepository {
  Future<Either<Failure, bool>> save(BleDeviceModel device);

  Future<Either<Failure, List<BleDeviceModel>>> getAll();

  Future<Either<Failure, bool>> clear();
}
