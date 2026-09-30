import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import '../../common/failure.dart';
import '../../common/helperText.dart';
import '../../domain/repositories/deviceHistoryRepository.dart';
import '../sources/db/database_helper_device.dart';
import '../sources/model/bleDeviceModel.dart';

class DeviceHistoryRepositoryImpl implements DeviceHistoryRepository {
  final DatabaseDeviceHelper _db = GetIt.instance.get<DatabaseDeviceHelper>();

  @override
  Future<Either<Failure, bool>> save(BleDeviceModel device) async {
    try {
      await _db.upsert(device);
      return Right(true);
    } catch (e) {
      return Left(DatabaseFailure(DATABASE_FAILURE));
    }
  }

  @override
  Future<Either<Failure, List<BleDeviceModel>>> getAll() async {
    try {
      return Right(await _db.all());
    } catch (e) {
      return Left(DatabaseFailure(DATABASE_FAILURE));
    }
  }

  @override
  Future<Either<Failure, bool>> clear() async {
    try {
      await _db.clear();
      return Right(true);
    } catch (e) {
      return Left(DatabaseFailure(DATABASE_FAILURE));
    }
  }
}
