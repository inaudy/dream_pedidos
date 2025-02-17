import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'stock_management_event.dart';
part 'stock_management_state.dart';

class StockManagementBloc
    extends Bloc<StockManagementEvent, StockManagementState> {
  final StockRepository stockRepository;
  final String posKey;

  StockManagementBloc(this.stockRepository, {required this.posKey})
      : super(const StockManagementInitial()) {
    on<LoadStockEvent>(_onLoadStock);
    on<UpdateStockItemEvent>(_onUpdateStockItem);
    on<DeleteAllStockEvent>(_onDeleteAllStock);
    on<BulkUpdateStockEvent>(_onBulkUpdateStock);
  }

  Future<void> _onLoadStock(
      LoadStockEvent event, Emitter<StockManagementState> emit) async {
    emit(const StockLoading());
    try {
      final stockItems = await stockRepository.getAllStockItems();
      emit(StockLoaded(
        stockItems,
        message: 'Stock data loaded successfully.',
        isSearchVisible: false,
        searchQuery: '',
      ));
    } catch (error) {
      emit(StockError('Failed to load stock: ${error.toString()}'));
    }
  }

  Future<void> _onUpdateStockItem(
      UpdateStockItemEvent event, Emitter<StockManagementState> emit) async {
    if (state is StockLoaded || state is StockUpdated) {
      final currentState = state as StockLoaded;
      try {
        // Locate the old item in the list (using itemName as unique identifier).
        final oldItem = currentState.stockItems.firstWhere(
          (item) => item.itemName == event.updatedItem.itemName,
        );

        // Update the item in the repository.
        await stockRepository.updateStockItem(event.updatedItem);

        // Compute the raw refill quantity:
        // If a nonzero refillQuantity was provided, use it; otherwise, calculate the difference.
        final double rawRefill = event.refillQuantity > 0
            ? event.refillQuantity
            : event.updatedItem.actualStock - oldItem.actualStock;

        // Adjust the refill for history by adding the error percentage.
        // For example, if rawRefill is 5 and errorPercentage is 10,
        // then historyRefill = 5 * (1 + 10/100) = 5.5.
        final double historyRefill =
            rawRefill * (1 + (oldItem.errorPercentage / 100.0));

        // Save refill history only if there's a positive refill.
        if (historyRefill > 0) {
          await stockRepository.saveRefillHistory(event.updatedItem.itemName,
              historyRefill, event.updatedItem.errorPercentage.toDouble());
        }

        // Create a new list with the updated item.
        final updatedStock = currentState.stockItems.map((item) {
          return item.itemName == event.updatedItem.itemName
              ? event.updatedItem
              : item;
        }).toList();

        // Emit a state to notify the UI about the updated item.
        emit(StockUpdated(
          stockItems: updatedStock,
          updatedItem: event.updatedItem,
        ));

        // Re-emit the full loaded state to refresh the list.
        emit(StockLoaded(
          List.from(updatedStock), // Force a new instance
          message: '', // No extra message
          isSearchVisible: currentState.isSearchVisible,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(StockError('Error updating stock: ${e.toString()}'));
      }
    }
  }
  Future<void> _onBulkUpdateStock(
      BulkUpdateStockEvent event, Emitter<StockManagementState> emit) async {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      emit(StockUpdating(currentState.stockItems));

      try {
        // Update all items concurrently (if your repository supports it)
        await Future.wait(event.updatedItems.map((item) async {
          await stockRepository.updateStockItem(item);
          // Optionally, update refill history here if needed.
        }));
        
        // After bulk updates, fetch the updated stock from the repository.
        final updatedStock = await stockRepository.getAllStockItems();
        emit(StockLoaded(
          List.from(updatedStock),
          message: 'Bulk update successful.',
          isSearchVisible: currentState.isSearchVisible,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(StockError('Bulk update error: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteAllStock(
      DeleteAllStockEvent event, Emitter<StockManagementState> emit) async {
    emit(const StockLoading()); // 🔹 Ensures UI refresh
    try {
      await stockRepository.resetStockFromBackup();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_sync_date_$posKey');

      final updatedStock = await stockRepository.getAllStockItems();

      emit(StockLoaded(
        updatedStock,
        message: 'Stock reset successfully.',
        isSearchVisible: false,
        searchQuery: '',
      ));
    } catch (error) {
      emit(StockError('Error resetting stock: ${error.toString()}'));
    }
  }
}
