import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../repositories/deviceHistoryRepository.dart';

class ClearHistory {
  final DeviceHistoryRepository repository;
  ClearHistory(this.repository);

  Future<Either<Failure, bool>> execute() => repository.clear();
}
