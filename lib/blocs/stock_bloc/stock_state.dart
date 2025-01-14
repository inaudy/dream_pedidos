import 'package:dream_pedidos/models/stock_item.dart';
import 'package:equatable/equatable.dart';

abstract class StockState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockItem> stockItems;

  StockLoaded(this.stockItems);

  @override
  List<Object?> get props => [stockItems];
}

class StockError extends StockState {
  final String error;

  StockError(this.error);

  @override
  List<Object?> get props => [error];
}
