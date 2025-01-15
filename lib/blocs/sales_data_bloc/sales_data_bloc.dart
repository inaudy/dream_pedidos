/*import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '/models/sales_data.dart';
import '/services/repositories/sales_repository.dart';

part 'sales_data_event.dart';
part 'sales_data_state.dart';

class SalesDataBloc extends Bloc<SalesDataEvent, SalesDataState> {
  final SalesRepository salesRepository;

  SalesDataBloc(this.salesRepository) : super(SalesDataInitial()) {
    on<SaveSalesDataEvent>((event, emit) async {
      emit(SalesDataLoading());
      try {
        await salesRepository.insertSalesData(event.salesData);
        emit(SalesDataSaved());
      } catch (e) {
        emit(SalesDataError(e.toString()));
      }
    });

    on<FetchSalesDataEvent>((event, emit) async {
      emit(SalesDataLoading());
      try {
        final data = await salesRepository.fetchSalesData(
          event.salesPointId,
          event.date,
        );
        emit(SalesDataLoaded(data));
      } catch (e) {
        emit(SalesDataError(e.toString()));
      }
    });
  }
}
*/