part of 'stock_sync_bloc.dart';

abstract class StockSyncState extends Equatable {
  const StockSyncState();

  @override
  List<Object> get props => [];
}

class StockSyncInitial extends StockSyncState {}

class StockSyncLoading extends StockSyncState {}

class StockSyncSuccess extends StockSyncState {}

class StockSyncError extends StockSyncState {
  final String message;
  const StockSyncError(this.message);

  @override
  List<Object> get props => [message];
}
