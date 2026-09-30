import '../repositories/bleRepository.dart';

class GetBluetoothState {
  final BleRepository repository;
  GetBluetoothState(this.repository);

  Stream<bool> execute() => repository.bluetoothOn();
}
