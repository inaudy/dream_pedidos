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
    on<ToggleSearchEvent>(_onToggleSearchEvent);
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

  /// 🔹 Update Stock Item
  Future<void> _onUpdateStockItem(
      UpdateStockItemEvent event, Emitter<StockManagementState> emit) async {
    if (state is StockLoaded) {
      try {
        await stockRepository.updateStockItem(event.updatedItem);
        final updatedStock = await stockRepository.getAllStockItems();

        final currentState = state as StockLoaded;
        emit(StockLoaded(
          updatedStock,
          message: 'Stock updated successfully.',
          isSearchVisible: currentState.isSearchVisible, // Preserve UI state
          searchQuery: currentState.searchQuery, // Preserve search state
        ));
      } catch (e) {
        emit(StockError('Error updating stock: ${e.toString()}'));
      }
    }
  }

  /// 🔹 Toggle Search Bar Visibility
  void _onToggleSearchEvent(
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
  }

  /// 🔹 Search Stock By Barcode (EAN-13)
  void _onSearchStockByEAN(
      SearchStockByEANEvent event, Emitter<StockManagementState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      final stockItems = currentState.stockItems;

      final matchingItem = stockItems.firstWhere(
        (item) => item.eanCode?.trim() == event.eanCode.trim(),
        orElse: () => StockItem(
          itemName: '',
          minimumLevel: 0,
          maximumLevel: 0,
          actualStock: 0,
          category: '',
          traspaso: '',
          eanCode: '',
          errorPercentage: 0,
        ),
      );

      if (matchingItem.itemName.isNotEmpty) {
        emit(StockEditDialogState(matchingItem));
      } else {
        emit(
            const StockError('No se encontró ningún producto con ese código.'));
      }
    }
  }

  /// 🔹 Update Search Query (User Typing)
  void _onUpdateSearchQuery(
      UpdateSearchQueryEvent event, Emitter<StockManagementState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      emit(StockLoaded(
        currentState.stockItems,
        message: currentState.message,
        isSearchVisible: currentState.isSearchVisible,
        searchQuery: event.searchQuery, // Update the search query
      ));
    }
  }

  /// 🔹 Delete All Stock Items
  Future<void> _onDeleteAllStock(
      DeleteAllStockEvent event, Emitter<StockManagementState> emit) async {
    emit(const StockLoading());
    try {
      await stockRepository.resetStockFromBackup();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_sync_date_$posKey');

      final updatedStock = await stockRepository.getAllStockItems();

      final currentState = state as StockLoaded;
      emit(StockLoaded(
        updatedStock,
        message: 'Stock reset successfully.',
        isSearchVisible: currentState.isSearchVisible, // Preserve state
        searchQuery: currentState.searchQuery, // Preserve search state
      ));
    } catch (error) {
      emit(StockError('Error resetting stock: ${error.toString()}'));
    }
  }
}
