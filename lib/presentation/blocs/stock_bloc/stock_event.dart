import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load Events
class LoadStockEvent extends StockEvent {}

class RefreshStockEvent extends StockEvent {} // For refreshing stock data

// Delete Events
class DeleteAllStockEvent extends StockEvent {}

class DeleteStockItemEvent extends StockEvent {
  final String itemId; // Use ID to identify the stock item

  DeleteStockItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class RemoveSelectedItemsEvent extends StockEvent {
  final List<StockItem> itemsToRemove;

  RemoveSelectedItemsEvent(this.itemsToRemove);

  @override
  List<Object?> get props => [itemsToRemove];
}

// Sync Events
class SyncStockEvent extends StockEvent {
  final List<SalesData> salesData;

  SyncStockEvent(this.salesData);

  @override
  List<Object?> get props => [salesData];
}

class SyncStockFromBackupEvent extends StockEvent {} // Sync from backup source

// Update Events
class UpdateStockEvent extends StockEvent {
  final StockItem updatedItem;

  UpdateStockEvent(this.updatedItem);

  @override
  List<Object?> get props => [updatedItem];
}

class BulkUpdateStockEvent extends StockEvent {
  final List<StockItem> updatedItems;

  BulkUpdateStockEvent(this.updatedItems);

  @override
  List<Object?> get props => [updatedItems];
}

// Add Events
class AddStockEvent extends StockEvent {
  final StockItem newItem;

  AddStockEvent(this.newItem);

  @override
  List<Object?> get props => [newItem];
}

class BulkAddStockEvent extends StockEvent {
  final List<StockItem> newItems;

  BulkAddStockEvent(this.newItems);

  @override
  List<Object?> get props => [newItems];
}

// Filter Events
class FilterStockEvent extends StockEvent {
  final String? keyword; // Search by keyword
  final bool? isLowStock; // Optional filter for low stock

  FilterStockEvent({this.keyword, this.isLowStock});

  @override
  List<Object?> get props => [keyword, isLowStock];
}

// Reset Event
class ResetStockEvent extends StockEvent {}
