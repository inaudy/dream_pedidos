import 'package:dream_pedidos/core/features/stock_managment/data/models/stock_item.dart';
import 'package:equatable/equatable.dart';

abstract class StockState extends Equatable {
  final String? message;
  const StockState({this.message});
  @override
  List<Object?> get props => [message];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockItem> stockItems;

  const StockLoaded(this.stockItems, {super.message});

  @override
  List<Object?> get props => [stockItems, message];
}

class StockError extends StockState {
  const StockError(String message) : super(message: message);

  @override
  List<Object?> get props => [message];
}
