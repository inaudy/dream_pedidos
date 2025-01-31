import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:intl/intl.dart'; // For date formatting

part 'stock_sync_event.dart';
part 'stock_sync_state.dart';

class StockSyncBloc extends Bloc<StockSyncEvent, StockSyncState> {
  final StockRepository stockRepository;
  final StockManagementBloc _stockManagementBloc;

  StockSyncBloc(this.stockRepository, this._stockManagementBloc)
      : super(StockSyncInitial()) {
    on<SyncStockEvent>(_onSyncStock);
  }

  Future<void> _onSyncStock(
      SyncStockEvent event, Emitter<StockSyncState> emit) async {
    emit(StockSyncLoading()); // Show loading

    try {
      // Get sales date from first sales entry
      final DateTime salesDate = event.salesData.first.date;

      // Check if this sales date was already synced
      final bool alreadySynced = await _isAlreadySynced(salesDate);
      if (alreadySynced) {
        emit(StockSyncError(
            "Error: Almacen ya actualizado con ventas del ${DateFormat('dd/MM/yyyy').format(salesDate)}"));
        return;
      }

      // Convert sales data to stock deductions
      final updatedSalesData = event.salesData.map((sale) {
        return {'item_name': sale.itemName, 'sales_volume': sale.salesVolume};
      }).toList();

      // Perform stock update
      await stockRepository.bulkUpdateStock(updatedSalesData);

      // Save last sync date
      await _saveLastSyncDate(salesDate);

      emit(StockSyncSuccess());
      _stockManagementBloc.add(LoadStockEvent());
    } catch (error) {
      emit(StockSyncError('Error al sincronizar stock: ${error.toString()}'));
    }
  }

  /// Saves the last sync date in SharedPreferences
  Future<void> _saveLastSyncDate(DateTime salesDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync_date', salesDate.toIso8601String());
  }

  /// Checks if the sales data for the given date is already synced
  Future<bool> _isAlreadySynced(DateTime salesDate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('last_sync_date');

    if (lastSyncString == null) return false; // No sync yet

    final lastSyncDate = DateTime.parse(lastSyncString);
    return DateUtils.isSameDay(lastSyncDate, salesDate);
  }
}
