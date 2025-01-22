import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavcubit extends Cubit<int> {
  BottomNavcubit() : super(0);
  void updateIndex(int index) => emit(index);
}
