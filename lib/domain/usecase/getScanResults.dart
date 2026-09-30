import '../../data/sources/model/bleDeviceModel.dart';
import '../repositories/bleRepository.dart';

class GetScanResults {
  final BleRepository repository;
  GetScanResults(this.repository);

  Stream<List<BleDeviceModel>> execute() => repository.scanResults();
}
