import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:equatable/equatable.dart';

part 'item_selection_state.dart';

class ItemSelectionCubit extends Cubit<ItemSelectionState> {
  ItemSelectionCubit() : super(ItemSelectionState());

  /// 🔹 Selects an item and tracks its refill quantity
  void selectItem(StockItem item) {
    final updatedSelection = Set<StockItem>.from(state.selectedItems)
      ..add(item);

    emit(state.copyWith(selectedItems: updatedSelection));
  }

  /// 🔹 Deselects an item and removes its refill quantity
  void deselectItem(StockItem item) {
    final updatedSelection = Set<StockItem>.from(state.selectedItems)
      ..remove(item);

    final updatedQuantities = Map<String, double>.from(state.quantities)
      ..remove(item.itemName);

    emit(state.copyWith(
        selectedItems: updatedSelection, quantities: updatedQuantities));
  }

  /// 🔹 Updates the refill quantity for a selected item
  void updateItemQuantity(String itemName, double quantity) {
    final updatedQuantities = Map<String, double>.from(state.quantities);
    updatedQuantities[itemName] = quantity;

    emit(state.copyWith(quantities: updatedQuantities));
  }

  /// 🔹 Clears selection and refill quantities after submission
  void clearSelection() {
    emit(ItemSelectionState()); // Reset to initial state
  }
}
