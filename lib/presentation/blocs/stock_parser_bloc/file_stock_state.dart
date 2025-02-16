part of 'file_stock_bloc.dart';

abstract class FileStockState extends Equatable {
  const FileStockState();

  @override
  List<Object> get props => [];
}

class FileStockInitial extends FileStockState {}

class FileStockLoading extends FileStockState {}

class FileStockUploadSuccess extends FileStockState {
  final List<StockItem> stockItems;

  const FileStockUploadSuccess(this.stockItems);

  @override
  List<Object> get props => [stockItems];
}

/// 🔹 Add `errorMessage` to fix the missing getter
class FileStockUploadFailure extends FileStockState {
  final String errorMessage;

  const FileStockUploadFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
