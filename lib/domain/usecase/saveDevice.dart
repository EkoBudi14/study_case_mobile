import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../../data/sources/model/bleDeviceModel.dart';
import '../repositories/deviceHistoryRepository.dart';

class SaveDevice {
  final DeviceHistoryRepository repository;
  SaveDevice(this.repository);

  Future<Either<Failure, bool>> execute(BleDeviceModel device) =>
      repository.save(device);
}
