part of 'stock_management_bloc.dart';

abstract class StockManagementState extends Equatable {
  const StockManagementState();

  @override
  List<Object> get props => [];
}

/// 🔹 Initial state (before anything loads)
class StockManagementInitial extends StockManagementState {
  const StockManagementInitial();
}

/// 🔹 Loading state (when fetching stock data)
class StockLoading extends StockManagementState {
  const StockLoading();
}

class StockUpdating extends StockManagementState {
  final List<StockItem> updatingItems;
  const StockUpdating(this.updatingItems);

  @override
  List<Object> get props => [updatingItems];
}


/// 🔹 Updated state (when a single item updates)
class StockUpdated extends StockManagementState {
  final List<StockItem> stockItems; // ✅ Full stock list
  final StockItem updatedItem; // ✅ The recently updated item

  const StockUpdated({
    required this.stockItems,
    required this.updatedItem,
  });

  @override
  List<Object> get props => [stockItems, updatedItem];
}

/// 🔹 Main Stock Loaded state (UI shows stock data)
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
  List<Object> get props => [stockItems, message, isSearchVisible, searchQuery];
}

/// 🔹 Error state (when something goes wrong)
class StockError extends StockManagementState {
  final String message;
  const StockError(this.message);

  @override
  List<Object> get props => [message];
}
