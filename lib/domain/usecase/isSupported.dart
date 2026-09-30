import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../repositories/bleRepository.dart';

class IsSupported {
  final BleRepository repository;
  IsSupported(this.repository);

  Future<Either<Failure, bool>> execute() => repository.isSupported();
}
