import 'package:dream_pedidos/data/repositories/cocktail_recipe_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'stock_event.dart';
import 'stock_state.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository stockRepository;
  final CocktailRecipeRepository cocktailRecipeRepository;

  StockBloc(this.stockRepository, this.cocktailRecipeRepository)
      : super(StockInitial()) {
    on<LoadStockEvent>(_onLoadStock);
    on<DeleteAllStockEvent>(_onDeleteAllStock);
    on<SyncStockEvent>(_onSyncStock);
    on<SearchStockEvent>(_onSearchStock);
    on<ToggleSearchEvent>((event, emit) {
      if (state is StockLoaded) {
        final currentState = state as StockLoaded;
        // Toggle the visibility
        emit(StockLoaded(
          currentState.stockItems,
          filteredStockItems: currentState.filteredStockItems,
          isSearchVisible: !currentState.isSearchVisible, // Toggle visibility
          message: currentState.message,
        ));
      }
    });
  }

  Future<void> _onRemoveSelectedItems(
      RemoveSelectedItemsEvent event, Emitter<StockState> emit) async {
    if (state is StockLoaded) {
      final currentItems = (state as StockLoaded).stockItems;

      // Filter out items that are being removed
      final updatedItems = currentItems
          .where((item) => !event.itemsToRemove.contains(item))
          .toList();

      emit(StockLoaded(updatedItems,
          message: 'Items seleccionados eliminados.'));
    }
  }

  Future<void> _onSearchStock(
      SearchStockEvent event, Emitter<StockState> emit) async {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;

      // Split the query into words and filter stock items
      final queryWords = event.query.toLowerCase().split(' ');
      final filteredItems = currentState.stockItems.where((item) {
        final itemName = item.itemName.toLowerCase();
        return queryWords.every((word) => itemName.contains(word));
      }).toList();

      // Emit state with updated filtered items, keeping `isSearchVisible` as is
      emit(StockLoaded(
        currentState.stockItems,
        filteredStockItems: filteredItems,
        isSearchVisible: currentState.isSearchVisible, // Preserve visibility
        message: currentState.message,
      ));
    }
  }

  /// Handle stock synchronization event
  Future<void> _onSyncStock(
      SyncStockEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // Transform sales data to ingredient-based deductions
      final salesData = event.salesData
          .map((sale) => {
                'item_name': sale.itemName,
                'sales_volume': sale.salesVolume,
              })
          .toList();

      // Use cocktail recipes to convert sales to ingredient-based deductions
      final updatedSalesData = await _applyCocktailConversions(salesData);

      // Perform bulk stock updates
      await stockRepository.bulkUpdateStock(updatedSalesData);

      // Load updated stock items
      final updatedStock = await stockRepository.getAllStockItems();
      emit(StockLoaded(
        updatedStock,
        message: 'Stock synchronization completed successfully!',
      ));
    } catch (e) {
      emit(StockError('Failed to synchronize stock: ${e.toString()}'));
    }
  }

  /// Handle stock loading event
  Future<void> _onLoadStock(
      LoadStockEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      final stockItems = await stockRepository.getAllStockItems();
      emit(StockLoaded(stockItems, message: 'Stock data loaded successfully.'));
    } catch (error) {
      emit(StockError('Failed to load stock: ${error.toString()}'));
    }
  }

  /// Handle stock deletion and restoration event
  Future<void> _onDeleteAllStock(
      DeleteAllStockEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // Reset stock from backup
      await stockRepository.resetStockFromBackup();

      // Reload the stock items
      final updatedStock = await stockRepository.getAllStockItems();
      emit(StockLoaded(updatedStock, message: 'Stock reset completed.'));
    } catch (error) {
      emit(StockError('Failed to reset stock: ${error.toString()}'));
    }
  }

  /// Convert sales data using cocktail recipes
  Future<List<Map<String, dynamic>>> _applyCocktailConversions(
      List<Map<String, dynamic>> salesData) async {
    final updatedSalesData = <Map<String, dynamic>>[];

    for (var sale in salesData) {
      final itemName = sale['item_name'] as String;
      final salesVolume = sale['sales_volume'] as double;

      // Check if the item is a cocktail using CocktailRecipeRepository
      final ingredients =
          await cocktailRecipeRepository.getIngredientsByCocktail(itemName);

      if (ingredients.isNotEmpty) {
        // Map each ingredient to its corresponding sales volume
        for (var ingredient in ingredients) {
          updatedSalesData.add({
            'item_name': ingredient.ingredientName,
            'sales_volume': salesVolume * ingredient.quantity,
          });
        }
      } else {
        // If no ingredients found, keep the original item
        updatedSalesData.add(sale);
      }
    }

    return updatedSalesData;
  }
}
