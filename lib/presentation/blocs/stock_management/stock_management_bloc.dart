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
  }

  Future<void> _onToggleSearchEvent(
      ToggleSearchEvent event, Emitter<StockManagementState> emit) async {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      emit(StockLoaded(
        currentState.stockItems,
        message: currentState.message,
        isSearchVisible: !currentState.isSearchVisible, // Toggle visibility
      ));
    }
  }

  Future<void> _onLoadStock(
      LoadStockEvent event, Emitter<StockManagementState> emit) async {
    emit(StockLoading());
    try {
      final stockItems = await stockRepository.getAllStockItems();
      emit(StockLoaded(stockItems, message: 'Stock data loaded successfully.'));
    } catch (error) {
      emit(StockError('Failed to load stock: ${error.toString()}'));
    }
  }

  Future<void> _onUpdateStockItem(
      UpdateStockItemEvent event, Emitter<StockManagementState> emit) async {
    if (state is StockLoaded) {
      try {
        await stockRepository.updateStockItem(event.updatedItem);
        final updatedStock = await stockRepository.getAllStockItems();
        emit(StockLoaded(updatedStock, message: 'Stock updated successfully.'));
      } catch (e) {
        emit(StockError('Error updating stock: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteAllStock(
      DeleteAllStockEvent event, Emitter<StockManagementState> emit) async {
    emit(StockLoading());
    try {
      await stockRepository.resetStockFromBackup();
      final updatedStock = await stockRepository.getAllStockItems();
      emit(StockLoaded(updatedStock, message: 'Stock reset successfully.'));
    } catch (error) {
      emit(StockError('Error resetting stock: ${error.toString()}'));
    }
  }
}
