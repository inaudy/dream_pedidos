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
  final String posKey; // e.g., "restaurant", "bar", or "beachClub"

  StockManagementBloc(this.stockRepository, {required this.posKey})
      : super(const StockManagementInitial()) {
    on<LoadStockEvent>(_onLoadStock);
    on<UpdateStockItemEvent>(_onUpdateStockItem);
    on<DeleteAllStockEvent>(_onDeleteAllStock);
    //on<ToggleSearchEvent>(_onToggleSearchEvent);
  }

  /// 🔹 Load Stock Items
  Future<void> _onLoadStock(
      LoadStockEvent event, Emitter<StockManagementState> emit) async {
    emit(const StockLoading());
    try {
      final stockItems = await stockRepository.getAllStockItems();
      emit(StockLoaded(
        stockItems,
        message: 'Stock data loaded successfully.',
        isSearchVisible: false, // Ensure visibility is defined
        searchQuery: '',
      ));
    } catch (error) {
      emit(StockError('Failed to load stock: ${error.toString()}'));
    }
  }

  Future<void> _onUpdateStockItem(
      UpdateStockItemEvent event, Emitter<StockManagementState> emit) async {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;

      try {
        await stockRepository.updateStockItem(event.updatedItem);

        // 🔹 Efficiently update only the modified item
        final updatedStock = currentState.stockItems.map((item) {
          return item.itemName == event.updatedItem.itemName
              ? event.updatedItem
              : item;
        }).toList();

        emit(StockLoaded(
          updatedStock,
          message: 'Stock updated successfully.',
          isSearchVisible: currentState.isSearchVisible,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(StockError('Error updating stock: ${e.toString()}'));
      }
    }
  }

  /// 🔹 Toggle Search Bar Visibility
  /*void _onToggleSearchEvent(
      ToggleSearchEvent event, Emitter<StockManagementState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      emit(StockLoaded(
        currentState.stockItems,
        message: currentState.message,
        isSearchVisible: !currentState.isSearchVisible, // Toggle visibility
        searchQuery: currentState.searchQuery,
      ));
    }
  }*/

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
