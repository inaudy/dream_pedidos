import 'package:bloc/bloc.dart';
import '/models/stock_item.dart';
import 'package:equatable/equatable.dart';

// Event for toggling item selection
class ItemSelectionEvent extends Equatable {
  final StockItem item;
  const ItemSelectionEvent(this.item);

  @override
  List<Object> get props => [item];
}

// State for managing selected items
class ItemSelectionState extends Equatable {
  final Set<StockItem> selectedItems;
  const ItemSelectionState(this.selectedItems);

  @override
  List<Object> get props => [selectedItems];

  ItemSelectionState copyWith({Set<StockItem>? selectedItems}) {
    return ItemSelectionState(selectedItems ?? this.selectedItems);
  }
}

// Cubit to manage selection of items
class ItemSelectionCubit extends Cubit<ItemSelectionState> {
  ItemSelectionCubit() : super(ItemSelectionState({}));

  void toggleItemSelection(StockItem item) {
    final selectedItems = Set<StockItem>.from(state.selectedItems);
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
    emit(state.copyWith(selectedItems: selectedItems));
  }
}
