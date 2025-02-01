import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/datasources/external/file_parser.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:equatable/equatable.dart';
part 'file_stock_event.dart';
part 'file_stock_state.dart';

class FileStockBloc extends Bloc<FileStockEvent, FileStockState> {
  final StockRepository _stockRepository;
  final StockManagementBloc _stockManagementBloc;
  FileStockBloc(this._stockRepository, this._stockManagementBloc)
      : super(FileStockInitial()) {
    on<FileStockUploadEvent>((event, emit) async {
      emit(FileStockLoading());
      try {
        final stockDataList = await FileParser.parseStockFile(event.filePath);

        await _stockRepository.addStockItems(stockDataList);

        emit(FileStockUploadSuccess(stockDataList));
        _stockManagementBloc.add(LoadStockEvent());
      } catch (e) {
        emit(FileStockUploadFailure(e.toString()));
      }
    });
  }
}
