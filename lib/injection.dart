import 'package:get_it/get_it.dart';

import 'data/repositories/bleRepositoryImpl.dart';
import 'data/repositories/deviceHistoryRepositoryImpl.dart';
import 'data/sources/db/database_helper_device.dart';
import 'domain/repositories/bleRepository.dart';
import 'domain/repositories/deviceHistoryRepository.dart';
import 'domain/usecase/clearHistory.dart';
import 'domain/usecase/getBluetoothState.dart';
import 'domain/usecase/getHistory.dart';
import 'domain/usecase/getScanningState.dart';
import 'domain/usecase/getScanResults.dart';
import 'domain/usecase/isScanning.dart';
import 'domain/usecase/isSupported.dart';
import 'domain/usecase/requestPermissions.dart';
import 'domain/usecase/saveDevice.dart';
import 'domain/usecase/startScan.dart';
import 'domain/usecase/stopScan.dart';
import 'presentation/pages/historyScreen/blocHistory/history_bloc.dart';
import 'presentation/pages/scannerScreen/blocScanner/scanner_bloc.dart';
import 'presentation/pages/trackerScreen/blocTracker/tracker_bloc.dart';
import 'services/ble_service.dart';

final locator = GetIt.instance;

void init() {
  initRepository();
  initUseCase();
  initBloc();

  locator.registerLazySingleton(() => BleService());
  locator.registerLazySingleton(() => DatabaseDeviceHelper());
}

void initRepository() {
  locator.registerLazySingleton<BleRepository>(() => BleRepositoryImpl());
  locator.registerLazySingleton<DeviceHistoryRepository>(
    () => DeviceHistoryRepositoryImpl(),
  );
}

void initUseCase() {
  locator.registerLazySingleton(() => IsSupported(locator()));
  locator.registerLazySingleton(() => RequestPermissions(locator()));
  locator.registerLazySingleton(() => GetBluetoothState(locator()));
  locator.registerLazySingleton(() => GetScanResults(locator()));
  locator.registerLazySingleton(() => GetScanningState(locator()));
  locator.registerLazySingleton(() => StartScan(locator()));
  locator.registerLazySingleton(() => StopScan(locator()));
  locator.registerLazySingleton(() => IsScanning(locator()));
  locator.registerLazySingleton(() => SaveDevice(locator()));
  locator.registerLazySingleton(() => GetHistory(locator()));
  locator.registerLazySingleton(() => ClearHistory(locator()));
}

void initBloc() {
  // Scanner
  locator.registerLazySingleton(
    () => ScannerBloc(
      isSupported: locator(),
      requestPermissions: locator(),
      getBluetoothState: locator(),
      getScanResults: locator(),
      getScanningState: locator(),
      startScan: locator(),
      stopScan: locator(),
      saveDevice: locator(),
    ),
  );
  locator.registerFactory(
    () => TrackerBloc(
      getScanResults: locator(),
      startScan: locator(),
      stopScan: locator(),
    ),
  );
  locator.registerFactory(
    () => HistoryBloc(getHistory: locator(), clearHistory: locator()),
  );
}
