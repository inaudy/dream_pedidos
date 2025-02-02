import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/data/models/refill_history_item.dart';
import 'package:equatable/equatable.dart';

part 'refill_history_event.dart';
part 'refill_history_state.dart';

class RefillHistoryBloc extends Bloc<RefillHistoryEvent, RefillHistoryState> {
  final StockRepository _stockRepository;

  RefillHistoryBloc(this._stockRepository) : super(RefillHistoryLoading()) {
    on<LoadRefillHistoryEvent>(_onLoadRefillHistory);
    on<RevertRefillEvent>(_onRevertRefill);
  }

  // 🔹 Load refill history from the database
  Future<void> _onLoadRefillHistory(
      LoadRefillHistoryEvent event, Emitter<RefillHistoryState> emit) async {
    emit(RefillHistoryLoading());
    try {
      final history = await _stockRepository.getRefillHistory();
      emit(RefillHistoryLoaded(history));
    } catch (e) {
      emit(RefillHistoryError("Error loading history: ${e.toString()}"));
    }
  }

  // 🔹 Revert a refill entry (Restore the quantity to the stock table)
  Future<void> _onRevertRefill(
      RevertRefillEvent event, Emitter<RefillHistoryState> emit) async {
    try {
      await _stockRepository.revertRefill(event.refillId);
      final updatedHistory = await _stockRepository.getRefillHistory();
      emit(RefillHistoryLoaded(updatedHistory)); // Refresh UI
    } catch (e) {
      emit(RefillHistoryError("Error reverting refill: ${e.toString()}"));
    }
  }
}
