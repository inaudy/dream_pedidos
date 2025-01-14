import 'package:dream_pedidos/models/sales_data.dart';
import 'package:equatable/equatable.dart';
import '/models/stock_item.dart';

abstract class StockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteAllStockEvent extends StockEvent {}

class LoadStockEvent extends StockEvent {}

class SyncStockEvent extends StockEvent {
  final List<SalesData> salesData;

  SyncStockEvent(this.salesData);
}

class UpdateStockEvent extends StockEvent {
  final StockItem updatedItem;

  UpdateStockEvent(this.updatedItem);

  @override
  List<Object?> get props => [updatedItem];
}

class AddStockEvent extends StockEvent {
  final StockItem newItem;

  AddStockEvent(this.newItem);

  @override
  List<Object?> get props => [newItem];
}
