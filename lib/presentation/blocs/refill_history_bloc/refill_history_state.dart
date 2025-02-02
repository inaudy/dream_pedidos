part of 'refill_history_bloc.dart';

abstract class RefillHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

// 🔹 Initial state when the history is loading
class RefillHistoryLoading extends RefillHistoryState {}

// 🔹 Loaded state when history data is available
class RefillHistoryLoaded extends RefillHistoryState {
  final List<RefillHistoryItem> historyItems;

  RefillHistoryLoaded(this.historyItems);

  @override
  List<Object?> get props => [historyItems];
}

// 🔹 Error state if something goes wrong
class RefillHistoryError extends RefillHistoryState {
  final String message;

  RefillHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
