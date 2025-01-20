import 'package:dream_pedidos/services/repositories/cocktail_recipe_repository.dart';
import 'package:dream_pedidos/utils/event_bus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'stock_event.dart';
import 'stock_state.dart';
import 'package:dream_pedidos/services/repositories/stock_repository.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository stockRepository;
  final CocktailRecipeRepository cocktailRecipeRepository;

  StockBloc(this.stockRepository, this.cocktailRecipeRepository)
      : super(StockInitial()) {
    on<LoadStockEvent>(_onLoadStock);
    on<DeleteAllStockEvent>(_onDeleteAllStock);
    on<SyncStockEvent>(_onSyncStock);

    // Listen for stock updates and reload when needed
    eventBus.stream.listen((event) {
      if (event == 'stock_updated') {
        add(LoadStockEvent());
      }
    });
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
      // Clear all stock items
      await stockRepository.deleteAllStockItems();

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
