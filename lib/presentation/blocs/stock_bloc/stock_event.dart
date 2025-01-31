/*import 'package:equatable/equatable.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';

abstract class StockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStockEvent extends StockEvent {}

class DeleteAllStockEvent extends StockEvent {}

class ToggleSearchEvent extends StockEvent {}

class SyncStockEvent extends StockEvent {
  final List<dynamic> salesData;

  SyncStockEvent(this.salesData);

  @override
  List<Object?> get props => [salesData];
}

class RemoveSelectedItemsEvent extends StockEvent {
  final List<StockItem> itemsToRemove;

  RemoveSelectedItemsEvent(this.itemsToRemove);

  @override
  List<Object?> get props => [itemsToRemove];
}

class SearchStockEvent extends StockEvent {
  final String query;

  SearchStockEvent(this.query);

  @override
  List<Object?> get props => [query];
}
*/