import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';

import 'package:equatable/equatable.dart';
import '../../../data/datasources/external/file_parser.dart';

part 'file_stock_event.dart';
part 'file_stock_state.dart';

class FileStockBloc extends Bloc<FileStockEvent, FileStockState> {
  final StockRepository _stockRepository;
  FileStockBloc(this._stockRepository) : super(FileStockInitial()) {
    on<FileStockUploadEvent>((event, emit) async {
      emit(FileStockLoading());
      try {
        final stockDataList = await FileParser.parseStockFile(event.filePath);

        await _stockRepository.addStockItems(stockDataList);

        emit(FileStockUploadSuccess(stockDataList));
      } catch (e) {
        emit(FileStockUploadFailure(e.toString()));
      }
    });
  }
}
