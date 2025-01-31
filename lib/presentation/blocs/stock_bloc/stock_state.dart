/*import 'package:equatable/equatable.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockItem> stockItems;
  final List<StockItem> filteredStockItems;
  final String? message;
  final bool isSearchVisible; // New property

  const StockLoaded(
    this.stockItems, {
    this.filteredStockItems = const [],
    this.message,
    this.isSearchVisible = false, // Default to hidden
  });

  @override
  List<Object?> get props =>
      [stockItems, filteredStockItems, message, isSearchVisible];
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}
*/