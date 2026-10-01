part of 'tracker_bloc.dart';

class TrackerState extends Equatable {
  const TrackerState();

  @override
  List<Object?> get props => [];
}

class TrackerInitial extends TrackerState {}

class TrackerUpdate extends TrackerState {
  final String name;
  final int rssi;
  final int secondsAgo;
  final DateTime lastSeen;

  const TrackerUpdate({
    required this.name,
    required this.rssi,
    required this.secondsAgo,
    required this.lastSeen,
  });

  @override
  List<Object?> get props => [name, rssi, secondsAgo, lastSeen];
}
