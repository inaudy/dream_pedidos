part of 'file_bloc.dart';

abstract class FileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileUploadEvent extends FileEvent {
  final String filePath;

  FileUploadEvent(this.filePath);
  @override
  List<Object?> get props => [filePath];
}
