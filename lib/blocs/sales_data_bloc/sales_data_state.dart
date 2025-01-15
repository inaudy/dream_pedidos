/*part of 'sales_data_bloc.dart';

abstract class SalesDataState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesDataInitial extends SalesDataState {}

class SalesDataLoading extends SalesDataState {}

class SalesDataLoaded extends SalesDataState {
  final List<SalesData> salesData;

  SalesDataLoaded(this.salesData);

  @override
  List<Object?> get props => [salesData];
}

class SalesDataSaved extends SalesDataState {}

class SalesDataError extends SalesDataState {
  final String error;

  SalesDataError(this.error);

  @override
  List<Object?> get props => [error];
}
*/