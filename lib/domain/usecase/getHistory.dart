import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../../data/sources/model/bleDeviceModel.dart';
import '../repositories/deviceHistoryRepository.dart';

class GetHistory {
  final DeviceHistoryRepository repository;
  GetHistory(this.repository);

  Future<Either<Failure, List<BleDeviceModel>>> execute() =>
      repository.getAll();
}
