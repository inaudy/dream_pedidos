// stock_upload_bloc.dart
import 'dart:async';
import 'package:dream_pedidos/blocs/stock_bloc/parser_event.dart';
import 'package:dream_pedidos/blocs/stock_bloc/parser_state.dart';
import 'package:dream_pedidos/services/repositories/stock_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/models/stock_item.dart';
import '../../utils/file_parser.dart';

class StockUploadBloc extends Bloc<StockUploadEvent, StockUploadState> {
  final StockRepository stockRepository;

  StockUploadBloc({required this.stockRepository})
      : super(StockUploadInitial()) {
    on<UploadStockFileEvent>(_onUploadStockFileEvent);
    on<BulkAddStockEvent>(_onBulkAddStockEvent);
  }

  Future<void> _onUploadStockFileEvent(
      UploadStockFileEvent event, Emitter<StockUploadState> emit) async {
    emit(StockUploadLoading());

    try {
      // Parse the file (XLSX or CSV)
      final stockItems = await FileParser.parseFile(event.filePath);

      // Convert SalesData to StockItem (adapt as needed)
      final stockItemList = stockItems.map((data) {
        return StockItem(
            itemName: data.itemName,
            actualStock: data.salesVolume.toInt(),
            minimumLevel: 10, // Default minimum level
            maximumLevel: 100, // Default maximum level
            categorie: '');
      }).toList();

      emit(StockUploadSuccess(stockItemList));
    } catch (e) {
      emit(StockUploadError('Failed to upload stock: $e'));
    }
  }

  Future<void> _onBulkAddStockEvent(
      BulkAddStockEvent event, Emitter<StockUploadState> emit) async {
    emit(StockUploadLoading());

    try {
      for (var item in event.stockItems) {
        await stockRepository.addStockItem(item);
      }
      emit(StockUploadSuccess(event.stockItems));
    } catch (e) {
      emit(StockUploadError('Failed to save stock items: $e'));
    }
  }
}
