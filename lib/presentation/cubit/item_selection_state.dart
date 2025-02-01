part of 'item_selection_cubit.dart';

class ItemSelectionState extends Equatable {
  final Set<StockItem> selectedItems;
  final Map<String, double> quantities;

  const ItemSelectionState({
    this.selectedItems = const {},
    this.quantities = const {},
  });

  /// 🔹 Copies state while updating selected items and quantities
  ItemSelectionState copyWith({
    Set<StockItem>? selectedItems,
    Map<String, double>? quantities,
  }) {
    return ItemSelectionState(
      selectedItems: selectedItems ?? this.selectedItems,
      quantities: quantities ?? this.quantities,
    );
  }

  @override
  List<Object> get props => [selectedItems, quantities];
}
