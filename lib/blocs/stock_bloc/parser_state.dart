// stock_upload_state.dart
import 'package:equatable/equatable.dart';
import '/models/stock_item.dart';

abstract class StockUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockUploadInitial extends StockUploadState {}

class StockUploadLoading extends StockUploadState {}

class StockUploadSuccess extends StockUploadState {
  final List<StockItem> uploadedItems;

  StockUploadSuccess(this.uploadedItems);

  @override
  List<Object?> get props => [uploadedItems];
}

class StockUploadError extends StockUploadState {
  final String message;

  StockUploadError(this.message);

  @override
  List<Object?> get props => [message];
}
