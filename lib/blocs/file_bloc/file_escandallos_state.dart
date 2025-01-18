part of 'file_escandallos_bloc.dart';

abstract class FileEscandallosState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileEscandallosInitial extends FileEscandallosState {}

class FileEscandallosLoading extends FileEscandallosState {}

class FileEscandallosUploadSuccess extends FileEscandallosState {
  final List<Conversion> stockData;

  FileEscandallosUploadSuccess(this.stockData);

  @override
  List<Object?> get props => [stockData];
}

class FileEscandallosUploadFailure extends FileEscandallosState {
  final String error;

  FileEscandallosUploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
