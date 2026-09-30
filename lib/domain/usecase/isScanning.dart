import '../repositories/bleRepository.dart';

class IsScanning {
  final BleRepository repository;
  IsScanning(this.repository);

  bool execute() => repository.isScanningNow;
}
