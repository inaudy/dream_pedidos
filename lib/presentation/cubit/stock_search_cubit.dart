import 'package:flutter_bloc/flutter_bloc.dart';

class StockSearchCubit extends Cubit<String> {
  StockSearchCubit() : super('');
  void updateSearchQuery(String query) {
    emit(query);
  }

  void clearSearch() {
    emit('');
  }
}
