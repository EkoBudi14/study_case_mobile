part of 'history_bloc.dart';

class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<BleDeviceModel> devices;
  const HistoryLoaded({required this.devices});

  @override
  List<Object?> get props => [devices];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
