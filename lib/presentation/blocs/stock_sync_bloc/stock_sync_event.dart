part of 'stock_sync_bloc.dart';

abstract class StockSyncEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to trigger stock synchronization
class SyncStockEvent extends StockSyncEvent {
  final List<SalesData> salesData;

  SyncStockEvent(this.salesData);

  @override
  List<Object?> get props => [salesData];
}
