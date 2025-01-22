part of 'sales_parser_bloc.dart';

abstract class SalesParserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesParserPickFileEvent extends SalesParserEvent {}

class SalesParserUploadEvent extends SalesParserEvent {
  final String filePath;

  SalesParserUploadEvent(this.filePath);
  @override
  List<Object?> get props => [filePath];
}
