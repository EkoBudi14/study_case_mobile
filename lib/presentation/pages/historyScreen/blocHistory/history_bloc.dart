import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/sources/model/bleDeviceModel.dart';
import '../../../../domain/usecase/clearHistory.dart';
import '../../../../domain/usecase/getHistory.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistory getHistory;
  final ClearHistory clearHistory;

  HistoryBloc({required this.getHistory, required this.clearHistory})
    : super(HistoryInitial()) {
    on<HistoryLoadData>(_onLoadData);
    on<HistoryClearData>(_onClearData);
  }

  Future<void> _onLoadData(
    HistoryLoadData event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final res = await getHistory.execute();
    res.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (devices) => emit(HistoryLoaded(devices: devices)),
    );
  }

  Future<void> _onClearData(
    HistoryClearData event,
    Emitter<HistoryState> emit,
  ) async {
    await clearHistory.execute();
    add(HistoryLoadData());
  }
}
