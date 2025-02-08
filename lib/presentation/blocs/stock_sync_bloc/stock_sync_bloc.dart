import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:dream_pedidos/data/repositories/recipe_repository.dart'; // Recipe repository interface

part 'stock_sync_event.dart';
part 'stock_sync_state.dart';

/// This bloc now also receives a recipe repository to apply conversion factors.
/// For each sale, it will look up all recipe rows, and for each row update the stock for that ingredient.
class StockSyncBloc extends Bloc<SyncStockEvent, StockSyncState> {
  final StockRepository stockRepository;
  final StockManagementBloc _stockManagementBloc;
  final String posKey; // e.g., "restaurant", "bar", or "beachClub"
  final CocktailRecipeRepository recipeRepository; // New dependency

  StockSyncBloc(
    this.stockRepository,
    this._stockManagementBloc, {
    required this.posKey,
    required this.recipeRepository,
  }) : super(StockSyncInitial()) {
    on<SyncStockEvent>(_onSyncStock);
  }

  Future<void> _onSyncStock(
      SyncStockEvent event, Emitter<StockSyncState> emit) async {
    emit(StockSyncLoading()); // Show loading

    try {
      // Get sales date from first sales entry.
      final DateTime salesDate = event.salesData.first.date;

      // Check if this sales date was already synced for this POS.
      final bool alreadySynced = await _isAlreadySynced(salesDate);
      if (alreadySynced) {
        emit(StockSyncError(
            "Error: Almacén ya actualizado con ventas del ${DateFormat('dd/MM/yyyy').format(salesDate)}"));
        return;
      }

      // Create a list to hold all stock updates.
      final List<Map<String, dynamic>> updatedSalesData = [];

      // For each sale record, check for conversion recipes.
      for (final sale in event.salesData) {
        // Get all recipe rows for the sale item.
        final recipes =
            await recipeRepository.getIngredientsByCocktail(sale.itemName);
        if (recipes.isNotEmpty) {
          // For each conversion row, calculate the deduction.
          for (final recipe in recipes) {
            updatedSalesData.add({
              'item_name': recipe.ingredientName, // stock item to update
              'sales_volume': sale.salesVolume * recipe.quantity,
            });
          }
        } else {
          // No conversion found: fallback to a 1:1 conversion for the sale item.
          updatedSalesData.add({
            'item_name': sale.itemName,
            'sales_volume': sale.salesVolume,
          });
        }
      }

      // Perform stock update using the aggregated conversion data.
      await stockRepository.bulkUpdateStock(updatedSalesData);

      // Save last sync date (specific to this POS).
      await _saveLastSyncDate(salesDate);

      emit(StockSyncSuccess());
      _stockManagementBloc.add(LoadStockEvent());
    } catch (error) {
      emit(StockSyncError('Error al sincronizar stock: ${error.toString()}'));
    }
  }

  /// Saves the last sync date in SharedPreferences using a key specific to the POS.
  Future<void> _saveLastSyncDate(DateTime salesDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'last_sync_date_$posKey', salesDate.toIso8601String());
  }

  /// Checks if the sales data for the given date is already synced for this POS.
  Future<bool> _isAlreadySynced(DateTime salesDate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('last_sync_date_$posKey');
    if (lastSyncString == null) return false; // No sync yet.
    final lastSyncDate = DateTime.parse(lastSyncString);
    return DateUtils.isSameDay(lastSyncDate, salesDate);
  }
}
