part of 'sales_parser_bloc.dart';

abstract class SalesParserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesParserInitial extends SalesParserState {}

class SalesParserLoading extends SalesParserState {}

class SalesParserSuccess extends SalesParserState {
  final List<SalesData> salesData;

  SalesParserSuccess(this.salesData);

  @override
  List<Object?> get props => [salesData];
}

class SalesParserFailure extends SalesParserState {
  final String error;

  SalesParserFailure(this.error);

  @override
  List<Object?> get props => [error];
}
