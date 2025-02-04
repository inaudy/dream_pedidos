import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:equatable/equatable.dart';

part 'stock_management_event.dart';
part 'stock_management_state.dart';

class StockManagementBloc
    extends Bloc<StockManagementEvent, StockManagementState> {
  final StockRepository stockRepository;

  StockManagementBloc(this.stockRepository) : super(StockManagementInitial()) {
    on<LoadStockEvent>(_onLoadStock);
    on<UpdateStockItemEvent>(_onUpdateStockItem);
    on<DeleteAllStockEvent>(_onDeleteAllStock);
    on<ToggleSearchEvent>(_onToggleSearchEvent);
    on<SearchStockByEANEvent>(_onSearchStockByEAN);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
  }

  /// 🔹 Load Stock Items
  Future<void> _onLoadStock(
      LoadStockEvent event, Emitter<StockManagementState> emit) async {
    emit(StockLoading());
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
        ),
      );

      if (matchingItem.itemName.isNotEmpty) {
        // Emit new state to trigger the edit dialog
        emit(StockEditDialogState(matchingItem));
      } else {
        emit(StockError('No se encontró ningún producto con ese código.'));
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
    emit(StockLoading());
    try {
      await stockRepository.resetStockFromBackup();
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
