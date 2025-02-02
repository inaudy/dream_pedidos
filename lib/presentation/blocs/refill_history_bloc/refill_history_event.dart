part of 'refill_history_bloc.dart';

abstract class RefillHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 🔹 Load the refill history from the database
class LoadRefillHistoryEvent extends RefillHistoryEvent {}

// 🔹 Revert a specific refill entry
class RevertRefillEvent extends RefillHistoryEvent {
  final int refillId; // This ID comes from the database

  RevertRefillEvent(this.refillId);

  @override
  List<Object?> get props => [refillId];
}
