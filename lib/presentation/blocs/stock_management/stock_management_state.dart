part of 'stock_management_bloc.dart';

abstract class StockManagementState extends Equatable {
  @override
  List<Object> get props => [];
}

/// 🔹 Initial State
class StockManagementInitial extends StockManagementState {}

/// 🔹 Loading State
class StockLoading extends StockManagementState {}

/// 🔹 Stock Loaded
class StockLoaded extends StockManagementState {
  final List<StockItem> stockItems;
  final String message;
  final bool isSearchVisible;
  final String searchQuery;

  StockLoaded(
    this.stockItems, {
    this.message = '',
    this.isSearchVisible = false,
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [stockItems, message, isSearchVisible, searchQuery];
}

/// New State: Triggers Edit Dialog when barcode is matched
class StockEditDialogState extends StockManagementState {
  final StockItem stockItem;

  StockEditDialogState(this.stockItem);

  @override
  List<Object> get props => [stockItem];
}

/// 🔹 Error State
class StockError extends StockManagementState {
  final String message;
  StockError(this.message);

  @override
  List<Object> get props => [message];
}
