import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:equatable/equatable.dart';

abstract class StockState extends Equatable {
  final String? message;
  const StockState({this.message});

  @override
  List<Object?> get props => [message];
}

// Initial State
class StockInitial extends StockState {}

// Loading State (for any asynchronous operation)
class StockLoading extends StockState {}

// Loaded State (when stock data is successfully fetched)
class StockLoaded extends StockState {
  final List<StockItem> stockItems;

  const StockLoaded(this.stockItems, {super.message});

  @override
  List<Object?> get props => [stockItems, message];
}

// Error State (for handling failures)
class StockError extends StockState {
  const StockError(String message) : super(message: message);

  @override
  List<Object?> get props => [message];
}

// Syncing State (when stock is being synced)
class StockSyncing extends StockState {
  const StockSyncing({super.message});
}

// Synced State (when stock sync is completed successfully)
class StockSynced extends StockState {
  final List<StockItem>? updatedStockItems;

  const StockSynced({this.updatedStockItems, super.message});

  @override
  List<Object?> get props => [updatedStockItems, message];
}

// Updating State (for individual or bulk stock updates)
class StockUpdating extends StockState {
  const StockUpdating({super.message});
}

// Updated State (when stock update is completed successfully)
class StockUpdated extends StockState {
  final List<StockItem> updatedStockItems;

  const StockUpdated(this.updatedStockItems, {super.message});

  @override
  List<Object?> get props => [updatedStockItems, message];
}

// Resetting State (when stock is being reset)
class StockResetting extends StockState {
  const StockResetting({super.message});
}

// Reset State (when stock reset is completed)
class StockReset extends StockState {
  final List<StockItem>? resetStockItems;

  const StockReset({this.resetStockItems, super.message});

  @override
  List<Object?> get props => [resetStockItems, message];
}
