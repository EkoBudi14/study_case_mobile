import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../repositories/bleRepository.dart';

class StartScan {
  final BleRepository repository;
  StartScan(this.repository);

  Future<Either<Failure, bool>> execute() => repository.startScan();
}
