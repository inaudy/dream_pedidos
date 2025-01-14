/*import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '/models/stock_item.dart';
import '/models/refill_log.dart';

part 'refill_event.dart';
part 'refill_state.dart';

class RefillBloc extends Bloc<RefillEvent, RefillState> {
  RefillBloc() : super(RefillInitial()) {
    on<CalculateRefillEvent>((event, emit) {
      emit(RefillCalculating());

      final List<RefillLog> refillLogs = [];

      for (var stock in event.stockList) {
        int requiredStock = stock.maximumLevel - stock.actualStock;

        if (stock.actualStock < stock.minimumLevel && requiredStock > 0) {
          refillLogs.add(
            RefillLog(
              id: 0,
              salesPointId: stock.salesPointId,
              itemName: stock.itemName,
              refillAmount: requiredStock,
              date: DateTime.now(),
            ),
          );
        }
      }

      emit(RefillCalculated(refillLogs));
    });
  }
}
*/