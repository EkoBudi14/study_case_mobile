import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../repositories/bleRepository.dart';

class StopScan {
  final BleRepository repository;
  StopScan(this.repository);

  Future<Either<Failure, bool>> execute() => repository.stopScan();
}
