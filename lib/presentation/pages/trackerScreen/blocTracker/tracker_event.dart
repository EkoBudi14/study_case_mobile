part of 'tracker_bloc.dart';

class TrackerEvent extends Equatable {
  const TrackerEvent();

  @override
  List<Object?> get props => [];
}

class TrackerStarted extends TrackerEvent {
  final String deviceId;
  final String name;
  final int initialRssi;

  const TrackerStarted({
    required this.deviceId,
    required this.name,
    required this.initialRssi,
  });

  @override
  List<Object?> get props => [deviceId, name, initialRssi];
}

class TrackerDeviceUpdated extends TrackerEvent {
  final int rssi;
  final String name;
  const TrackerDeviceUpdated({required this.rssi, required this.name});

  @override
  List<Object?> get props => [rssi, name];
}

class TrackerTicked extends TrackerEvent {}
