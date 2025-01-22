import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/stock_item.dart';

class ItemSelectionState extends Equatable {
  final List<StockItem> selectedItems;
  final String? message;

  const ItemSelectionState({
    this.selectedItems = const [],
    this.message,
  });

  @override
  List<Object?> get props => [selectedItems, message];
}

class ItemSelectionCubit extends Cubit<ItemSelectionState> {
  ItemSelectionCubit() : super(const ItemSelectionState());

  /// Toggle the selection of a stock item
  void toggleItemSelection(StockItem item) {
    final selectedItems = List<StockItem>.from(state.selectedItems);
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }

    emit(ItemSelectionState(
      selectedItems: selectedItems,
    ));
  }

  /// Clear all selected items and optionally set a success message
  void clearSelection({String? message}) {
    emit(ItemSelectionState(
      selectedItems: const [],
      message: message,
    ));
  }

  /// Set an error message
  void setError(String error) {
    emit(ItemSelectionState(
      selectedItems: state.selectedItems,
      message: error,
    ));
  }
}
