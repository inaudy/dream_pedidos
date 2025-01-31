part of 'stock_management_bloc.dart';

abstract class StockManagementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockManagementInitial extends StockManagementState {}

class StockLoading extends StockManagementState {}

class StockLoaded extends StockManagementState {
  final List<StockItem> stockItems;
  final String? message;
  final bool isSearchVisible;

  StockLoaded(this.stockItems, {this.message, this.isSearchVisible = false});

  @override
  List<Object?> get props => [stockItems, message, isSearchVisible];
}

class StockError extends StockManagementState {
  final String message;

  StockError(this.message);

  @override
  List<Object?> get props => [message];
}
