part of 'file_stock_bloc.dart';

abstract class FileStockState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileStockInitial extends FileStockState {}

class FileStockLoading extends FileStockState {}

class FileStockUploadSuccess extends FileStockState {
  final List<StockItem> stockData;

  FileStockUploadSuccess(this.stockData);

  @override
  List<Object?> get props => [stockData];
}

class FileStockUploadFailure extends FileStockState {
  final String error;

  FileStockUploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
