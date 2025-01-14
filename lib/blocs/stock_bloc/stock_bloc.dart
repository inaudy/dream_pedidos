// stock_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'stock_event.dart';
import 'stock_state.dart';
import 'package:dream_pedidos/services/repositories/stock_repository.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository stockRepository;

  StockBloc(this.stockRepository) : super(StockInitial()) {
    on<LoadStockEvent>(_onLoadStock);
    on<DeleteAllStockEvent>(_onDeleteAllStock);
    on<SyncStockEvent>(_onSyncStock);
  }

  /// Handle stock synchronization event
  Future<void> _onSyncStock(
      SyncStockEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // Perform bulk stock update using sales data
      final salesData = event.salesData
          .map((sale) =>
              {'item_name': sale.itemName, 'sales_volume': sale.salesVolume})
          .toList();
      await stockRepository.bulkUpdateStock(salesData);

      // Load updated stock items after synchronization
      final updatedStock = await stockRepository.getAllStockItems();
      emit(StockLoaded(updatedStock));
    } catch (e) {
      emit(StockError('Failed to synchronize stock: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStock(
      LoadStockEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      print('load stock');
      final stockItems = await stockRepository.getAllStockItems();
      emit(StockLoaded(stockItems));
    } catch (error) {
      emit(StockError(error.toString()));
    }
  }

  Future<void> _onDeleteAllStock(
      DeleteAllStockEvent event, Emitter<StockState> emit) async {
    emit(StockLoading()); // Emit loading state during deletion
    try {
      await stockRepository.deleteAllStockItems();
      emit(StockLoaded([])); // Emit empty list after deletion
    } catch (error) {
      emit(StockError(error.toString()));
    }
  }
}
