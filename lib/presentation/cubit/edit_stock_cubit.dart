import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';

class StockItemEditState {
  final String itemName;
  final double minimumLevel;
  final double maximumLevel;
  final double actualStock;

  StockItemEditState({
    required this.itemName,
    required this.minimumLevel,
    required this.maximumLevel,
    required this.actualStock,
  });

  StockItemEditState copyWith({
    String? itemName,
    double? minimumLevel,
    double? maximumLevel,
    double? actualStock,
  }) {
    return StockItemEditState(
      itemName: itemName ?? this.itemName,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      maximumLevel: maximumLevel ?? this.maximumLevel,
      actualStock: actualStock ?? this.actualStock,
    );
  }
}

class StockItemEditCubit extends Cubit<StockItemEditState> {
  StockItemEditCubit(StockItem stockItem)
      : super(StockItemEditState(
          itemName: stockItem.itemName,
          minimumLevel: stockItem.minimumLevel,
          maximumLevel: stockItem.maximumLevel,
          actualStock: stockItem.actualStock,
        ));

  void itemNameChanged(String newName) {
    emit(state.copyWith(itemName: newName));
  }

  void minimumLevelChanged(String newMin) {
    final parsed = double.tryParse(newMin);
    if (parsed != null) {
      emit(state.copyWith(minimumLevel: parsed));
    }
  }

  void maximumLevelChanged(String newMax) {
    final parsed = double.tryParse(newMax);
    if (parsed != null) {
      emit(state.copyWith(maximumLevel: parsed));
    }
  }

  void actualStockChanged(String newActual) {
    final parsed = double.tryParse(newActual);
    if (parsed != null) {
      emit(state.copyWith(actualStock: parsed));
    }
  }
}
