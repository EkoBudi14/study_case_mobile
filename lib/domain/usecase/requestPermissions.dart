import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../repositories/bleRepository.dart';

class RequestPermissions {
  final BleRepository repository;
  RequestPermissions(this.repository);

  Future<Either<Failure, bool>> execute() => repository.requestPermissions();
}
