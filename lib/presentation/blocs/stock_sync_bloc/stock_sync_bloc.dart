import 'package:dream_pedidos/data/repositories/excel_service.dart';
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

/// Este bloc recibe además un recipe repository para aplicar factores de conversión.
/// Para cada venta, busca las filas de recetas correspondientes y actualiza el stock de cada ingrediente.
class StockSyncBloc extends Bloc<SyncStockEvent, StockSyncState> {
  final StockRepository stockRepository;
  final StockManagementBloc _stockManagementBloc;
  final String posKey; // e.g., "restaurant", "bar", o "beachClub"
  final CocktailRecipeRepository recipeRepository; // Nueva dependencia

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
    emit(StockSyncLoading());

    try {
      bool alreadySynced = false;
      DateTime syncReferenceDate;
      List<Map<String, dynamic>> updatedSalesData = [];

      if (posKey == 'Beach Club') {
        final now = DateTime.now();
        // Se normaliza la fecha de hoy (sin componente horario)
        final normalizedToday = DateTime(now.year, now.month, now.day);
        syncReferenceDate = normalizedToday;

        alreadySynced = await _isAlreadySynced(syncReferenceDate);
        if (alreadySynced) {
          emit(StockSyncError(
              "Error: Almacén ya actualizado para la fecha ${DateFormat('dd/MM/yyyy').format(syncReferenceDate)}"));
          return;
        }

        // Como el SalesParserBloc ya filtra el período, se procesa directamente la data.
        for (final sale in event.salesData) {
          updatedSalesData.add({
            'item_name': sale.itemName,
            'sales_volume': sale.salesVolume,
          });
        }
      } else if (posKey == 'restaurant') {
        // Se asume que la lista ya está filtrada para las ventas de ayer.
        // Se guarda la fecha de ayer normalizada para evitar duplicados.
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final normalizedYesterday =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        syncReferenceDate = normalizedYesterday;

        alreadySynced = await _isAlreadySynced(syncReferenceDate);
        if (alreadySynced) {
          emit(StockSyncError(
              "Error: Almacén ya actualizado para la fecha ${DateFormat('dd/MM/yyyy').format(syncReferenceDate)}"));
          return;
        }

        for (final sale in event.salesData) {
          updatedSalesData.add({
            'item_name': sale.itemName,
            'sales_volume': sale.salesVolume,
          });
        }
      } else {
        // Caso por defecto para otros POS (se puede ajustar si es necesario)
        syncReferenceDate = event.salesData.first.date;
        alreadySynced = await _isAlreadySynced(syncReferenceDate);

        if (alreadySynced) {
          emit(StockSyncError(
              "Error: Almacén ya actualizado para la ${DateFormat('dd/MM/yyyy').format(syncReferenceDate)}"));
          return;
        }

        for (final sale in event.salesData) {
          updatedSalesData.add({
            'item_name': sale.itemName,
            'sales_volume': sale.salesVolume,
          });
        }
      }

      await ExcelService.sendEmailWithExcelFromDB(stockRepository, posKey);
      // Realiza la actualización del stock
      await stockRepository.bulkUpdateStock(updatedSalesData);
      _stockManagementBloc.add(LoadStockEvent());
      // Guarda la fecha de sincronización
      await _saveLastSyncDate(syncReferenceDate);

      emit(StockSyncSuccess());
    } catch (error) {
      emit(StockSyncError('Error al sincronizar stock: ${error.toString()}'));
    }
  }

  /// Guarda la última fecha de sincronización en SharedPreferences usando una llave específica para el POS.
  Future<void> _saveLastSyncDate(DateTime salesDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'last_sync_date_$posKey', salesDate.toIso8601String());
  }

  /// Verifica si los datos de venta para la fecha dada ya fueron sincronizados para este POS.
  Future<bool> _isAlreadySynced(DateTime salesDate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('last_sync_date_$posKey');
    if (lastSyncString == null) return false; // Aún no se ha sincronizado.
    final lastSyncDate = DateTime.parse(lastSyncString);
    if (posKey == 'restaurant') {
      return DateUtils.isSameDay(lastSyncDate, salesDate);
    } else {
      return posKey == 'beachClub'
          ? lastSyncDate.isAtSameMomentAs(salesDate)
          : DateUtils.isSameDay(lastSyncDate, salesDate);
    }
  }
}
