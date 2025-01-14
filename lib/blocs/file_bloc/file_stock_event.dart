part of 'file_stock_bloc.dart';

abstract class FileStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileStockUploadEvent extends FileStockEvent {
  final String filePath;

  FileStockUploadEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
