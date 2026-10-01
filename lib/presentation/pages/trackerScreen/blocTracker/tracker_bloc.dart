import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/sources/model/bleDeviceModel.dart';
import '../../../../domain/usecase/getScanResults.dart';
import '../../../../domain/usecase/startScan.dart';
import '../../../../domain/usecase/stopScan.dart';

part 'tracker_event.dart';
part 'tracker_state.dart';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  final GetScanResults getScanResults;
  final StartScan startScan;
  final StopScan stopScan;

  static const _smoothing = 0.15;

  String _deviceId = '';
  String _name = '';
  double _rssi = 0;
  DateTime _lastSeen = DateTime.now();

  StreamSubscription<List<BleDeviceModel>>? _sub;
  Timer? _ticker;

  TrackerBloc({
    required this.getScanResults,
    required this.startScan,
    required this.stopScan,
  }) : super(TrackerInitial()) {
    on<TrackerStarted>(_onStarted);
    on<TrackerDeviceUpdated>(_onDeviceUpdated);
    on<TrackerTicked>(_onTicked);
  }

  void _onStarted(TrackerStarted event, Emitter<TrackerState> emit) {
    _deviceId = event.deviceId;
    _name = event.name;
    _rssi = event.initialRssi.toDouble();
    _lastSeen = DateTime.now();

    stopScan.execute();
    startScan.execute();

    _emit(emit);

    _sub = getScanResults.execute().listen((devices) {
      for (final d in devices) {
        if (d.id == _deviceId) {
          add(TrackerDeviceUpdated(rssi: d.rssi, name: d.name));
          break;
        }
      }
    });

    _ticker = Timer.periodic(Duration(seconds: 1), (_) => add(TrackerTicked()));
  }

  void _onDeviceUpdated(
    TrackerDeviceUpdated event,
    Emitter<TrackerState> emit,
  ) {
    _lastSeen = DateTime.now();
    _name = event.name;
    _rssi += (event.rssi - _rssi) * _smoothing;
    _emit(emit);
  }

  void _onTicked(TrackerTicked event, Emitter<TrackerState> emit) =>
      _emit(emit);

  void _emit(Emitter<TrackerState> emit) {
    emit(
      TrackerUpdate(
        name: _name,
        rssi: _rssi.round(),
        secondsAgo: DateTime.now().difference(_lastSeen).inSeconds,
        lastSeen: _lastSeen,
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _ticker?.cancel();
    stopScan.execute();
    return super.close();
  }
}
