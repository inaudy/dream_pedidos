// pos_selection_cubit.dart
import 'package:bloc/bloc.dart';

enum PosType { restaurant, beachClub, bar }

extension PosTypeExtension on PosType {
  String get name {
    switch (this) {
      case PosType.restaurant:
        return "Restaurante";
      case PosType.beachClub:
        return "Beach Club";
      case PosType.bar:
        return "Bar Hall";
    }
  }
}

class PosSelectionCubit extends Cubit<PosType> {
  PosSelectionCubit() : super(PosType.restaurant);

  void selectPos(PosType pos) => emit(pos);
}
