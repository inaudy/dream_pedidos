// stock_upload_event.dart
import 'package:equatable/equatable.dart';
import '/models/stock_item.dart';

abstract class StockUploadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UploadStockFileEvent extends StockUploadEvent {
  final String filePath;

  UploadStockFileEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class BulkAddStockEvent extends StockUploadEvent {
  final List<StockItem> stockItems;

  BulkAddStockEvent(this.stockItems);

  @override
  List<Object?> get props => [stockItems];
}
