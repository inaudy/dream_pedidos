part of 'stock_management_bloc.dart';

abstract class StockManagementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStockEvent extends StockManagementEvent {}

class ToggleSearchEvent extends StockManagementEvent {}

class UpdateStockItemEvent extends StockManagementEvent {
  final StockItem updatedItem;

  UpdateStockItemEvent(this.updatedItem);

  @override
  List<Object?> get props => [updatedItem];
}

class DeleteAllStockEvent extends StockManagementEvent {}

class AddStockItemsEvent extends StockManagementEvent {
  final List<StockItem> newItems;

  AddStockItemsEvent(this.newItems);

  @override
  List<Object?> get props => [newItems];
}

class RemoveSelectedStockItemsEvent extends StockManagementEvent {
  final List<StockItem> itemsToRemove;

  RemoveSelectedStockItemsEvent(this.itemsToRemove);

  @override
  List<Object?> get props => [itemsToRemove];
}
