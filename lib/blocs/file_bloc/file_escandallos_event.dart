part of 'file_escandallos_bloc.dart';

abstract class FileEscandallosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileEscandallosUploadEvent extends FileEscandallosEvent {
  final String filePath;

  FileEscandallosUploadEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
