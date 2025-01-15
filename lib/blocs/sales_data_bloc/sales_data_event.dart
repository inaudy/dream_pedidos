/*part of 'sales_data_bloc.dart';

abstract class SalesDataEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveSalesDataEvent extends SalesDataEvent {
  final SalesData salesData;

  SaveSalesDataEvent(this.salesData);

  @override
  List<Object?> get props => [salesData];
}

class FetchSalesDataEvent extends SalesDataEvent {
  final int salesPointId;
  final String date;

  FetchSalesDataEvent(this.salesPointId, this.date);

  @override
  List<Object?> get props => [salesPointId, date];
}
*/