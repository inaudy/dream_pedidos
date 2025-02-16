part of 'stock_management_bloc.dart';

abstract class StockManagementEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// 🔹 Load Stock
class LoadStockEvent extends StockManagementEvent {}

/// 🔹 Update Stock Item
class UpdateStockItemEvent extends StockManagementEvent {
  final StockItem updatedItem;
  final double refillQuantity;
  UpdateStockItemEvent(this.updatedItem, this.refillQuantity);

  @override
  List<Object> get props => [updatedItem, refillQuantity];
}

/// 🔹 Delete All Stock Items
class DeleteAllStockEvent extends StockManagementEvent {}

/// 🔹 Toggle Search Visibility
class ToggleSearchEvent extends StockManagementEvent {}

/// 🔹 Search Stock By EAN (Barcode)
class SearchStockByEANEvent extends StockManagementEvent {
  final String eanCode;
  SearchStockByEANEvent(this.eanCode);

  @override
  List<Object> get props => [eanCode];
}

/// 🔹 Update Search Query (User Typing or Barcode)
class UpdateSearchQueryEvent extends StockManagementEvent {
  final String searchQuery;
  UpdateSearchQueryEvent(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}
