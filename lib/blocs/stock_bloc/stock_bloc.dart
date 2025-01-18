import 'package:dream_pedidos/services/repositories/escandallo_repository.dart';
import 'package:dream_pedidos/utils/event_bus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'stock_event.dart';
import 'stock_state.dart';
import 'package:dream_pedidos/services/repositories/stock_repository.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository stockRepository;
  final ConversionRepository
      conversionRepository; // Repository to handle conversions

  StockBloc(this.stockRepository, this.conversionRepository)
      : super(StockInitial()) {
    on<LoadStockEvent>(_onLoadStock);
    on<DeleteAllStockEvent>(_onDeleteAllStock);
    on<SyncStockEvent>(_onSyncStock);
    eventBus.stream.listen((event) {
      if (event == 'stock_updated') {
        add(LoadStockEvent()); // Trigger reload
      }
    });
  }

  /// Handle stock synchronization event with conversion logic
  Future<void> _onSyncStock(
      SyncStockEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // Perform bulk stock update using sales data
      final salesData = event.salesData
          .map((sale) =>
              {'item_name': sale.itemName, 'sales_volume': sale.salesVolume})
          .toList();

      // Apply conversion if available for each item in sales data
      final updatedSalesData = await _applyConversions(salesData);

      await stockRepository.bulkUpdateStock(updatedSalesData);

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
      await stockRepository.resetStockFromBackup();
      emit(StockLoaded(const [])); // Emit empty list after deletion
    } catch (error) {
      emit(StockError(error.toString()));
    }
  }

  // Apply conversion size to each item if it exists in the conversions table
  Future<List<Map<String, dynamic>>> _applyConversions(
      List<Map<String, dynamic>> salesData) async {
    final updatedSalesData = <Map<String, dynamic>>[];

    for (var sale in salesData) {
      final itemName = sale['item_name'] as String;

      // Check if a conversion exists for the item
      final conversion =
          await conversionRepository.getConversionByItemName(itemName);

      if (conversion != null) {
        // If conversion exists, adjust the sales volume by conversion size
        final convertedSalesVolume =
            sale['sales_volume'] * conversion.conversionSize;
        updatedSalesData.add({
          'item_name': itemName,
          'sales_volume': convertedSalesVolume,
        });
      } else {
        // If no conversion exists, keep the original sales volume
        updatedSalesData.add(sale);
      }
    }

    return updatedSalesData;
  }
}
