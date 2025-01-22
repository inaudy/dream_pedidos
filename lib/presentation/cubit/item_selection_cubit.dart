import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';

// State for ItemSelectionCubit
class ItemSelectionState extends Equatable {
  final List<StockItem> selectedItems;

  const ItemSelectionState({this.selectedItems = const []});

  ItemSelectionState copyWith({List<StockItem>? selectedItems}) {
    return ItemSelectionState(
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }

  @override
  List<Object?> get props => [selectedItems];
}

// Cubit for managing item selection
class ItemSelectionCubit extends Cubit<ItemSelectionState> {
  ItemSelectionCubit() : super(const ItemSelectionState());

  // Select an item
  void selectItem(StockItem item) {
    if (!state.selectedItems.contains(item)) {
      final updatedItems = List<StockItem>.from(state.selectedItems)..add(item);
      emit(state.copyWith(selectedItems: updatedItems));
    }
  }

  // Deselect an item
  void deselectItem(StockItem item) {
    if (state.selectedItems.contains(item)) {
      final updatedItems = List<StockItem>.from(state.selectedItems)
        ..remove(item);
      emit(state.copyWith(selectedItems: updatedItems));
    }
  }

  // Toggle item selection
  void toggleItemSelection(StockItem item) {
    if (state.selectedItems.contains(item)) {
      deselectItem(item);
    } else {
      selectItem(item);
    }
  }

  // Clear all selections
  void clearSelection() {
    emit(state.copyWith(selectedItems: []));
  }
}
