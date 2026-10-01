part of 'history_bloc.dart';

class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoadData extends HistoryEvent {}

class HistoryClearData extends HistoryEvent {}
