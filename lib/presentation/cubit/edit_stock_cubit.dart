import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';

class StockItemEditState {
  final String itemName;
  final double minimumLevel;
  final double maximumLevel;
  final double actualStock;
  final String traspaso;
  final int errorPercentage;

  StockItemEditState({
    required this.itemName,
    required this.minimumLevel,
    required this.maximumLevel,
    required this.actualStock,
    required this.traspaso,
    required this.errorPercentage,
  });

  StockItemEditState copyWith({
    String? itemName,
    double? minimumLevel,
    double? maximumLevel,
    double? actualStock,
    String? traspaso,
    int? errorPercentage,
  }) {
    return StockItemEditState(
      itemName: itemName ?? this.itemName,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      maximumLevel: maximumLevel ?? this.maximumLevel,
      actualStock: actualStock ?? this.actualStock,
      traspaso: traspaso ?? this.traspaso,
      errorPercentage: errorPercentage ?? this.errorPercentage,
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
          traspaso: stockItem.traspaso ?? '', // default to empty string if null
          errorPercentage:
              stockItem.errorPercentage ?? 0, // default to 0.0 if null
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

  void traspasoChanged(String newTraspaso) {
    emit(state.copyWith(traspaso: newTraspaso));
  }

  void errorPercentageChanged(String newError) {
    final parsed = int.tryParse(newError) ?? state.errorPercentage;
    emit(state.copyWith(errorPercentage: parsed));
  }
}
