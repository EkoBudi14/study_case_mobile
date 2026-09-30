import '../repositories/bleRepository.dart';

class GetScanningState {
  final BleRepository repository;
  GetScanningState(this.repository);

  Stream<bool> execute() => repository.scanningState();
}
