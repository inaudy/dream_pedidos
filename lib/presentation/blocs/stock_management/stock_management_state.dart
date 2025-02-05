part of 'stock_management_bloc.dart';

/// 🔹 Base Class for All Stock Management States
abstract class StockManagementState extends Equatable {
  const StockManagementState();

  @override
  List<Object?> get props => [];
}

/// 🔹 Initial State
class StockManagementInitial extends StockManagementState {
  const StockManagementInitial();
}

/// 🔹 Loading State
class StockLoading extends StockManagementState {
  const StockLoading();
}

/// 🔹 Stock Loaded (Main State)
class StockLoaded extends StockManagementState {
  final List<StockItem> stockItems;
  final String message;
  final bool isSearchVisible;
  final String searchQuery;

  const StockLoaded(
    this.stockItems, {
    this.message = '',
    this.isSearchVisible = false,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props =>
      [stockItems, message, isSearchVisible, searchQuery];
}

/// 🔹 State for Showing Edit Dialog When Barcode is Matched
class StockEditDialogState extends StockManagementState {
  final StockItem stockItem;

  const StockEditDialogState(this.stockItem);

  @override
  List<Object?> get props => [stockItem];
}

/// 🔹 **New State for Barcode Scanning Result**

/// 🔹 Error State
class StockError extends StockManagementState {
  final String message;

  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}
