part of 'file_bloc.dart';

abstract class FileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileUploadSuccess extends FileState {
  final List<SalesData> salesData;

  FileUploadSuccess(this.salesData);

  @override
  List<Object?> get props => [salesData];
}

class FileUploadFailure extends FileState {
  final String error;

  FileUploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
