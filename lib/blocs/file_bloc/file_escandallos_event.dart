part of 'file_escandallos_bloc.dart';

abstract class FileEscandallosEvent extends Equatable {
  const FileEscandallosEvent();

  @override
  List<Object> get props => [];
}

class FileEscandallosUploadEvent extends FileEscandallosEvent {
  final String filePath;

  const FileEscandallosUploadEvent(this.filePath);

  @override
  List<Object> get props => [filePath];
}
