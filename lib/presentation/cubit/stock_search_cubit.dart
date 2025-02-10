import 'package:flutter_bloc/flutter_bloc.dart';

class StockSearchCubit extends Cubit<StockSearchState> {
  StockSearchCubit() : super(StockSearchState(query: '', isVisible: false));

  void updateSearchQuery(String query) {
    emit(state.copyWith(query: query));
  }

  void toggleSearch() {
    emit(state.copyWith(isVisible: !state.isVisible));
  }

  void clearSearch() {
    emit(state.copyWith(query: ''));
  }
}

// 🔹 State class for search functionality
class StockSearchState {
  final String query;
  final bool isVisible;

  StockSearchState({required this.query, required this.isVisible});

  // ✅ Helper method to copy state with modifications
  StockSearchState copyWith({String? query, bool? isVisible}) {
    return StockSearchState(
      query: query ?? this.query,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
