part of 'file_escandallos_bloc.dart';

abstract class FileEscandallosState extends Equatable {
  const FileEscandallosState();

  @override
  List<Object?> get props => [];
}

class FileEscandallosInitial extends FileEscandallosState {}

class FileEscandallosLoading extends FileEscandallosState {}

class FileEscandallosUploadSuccess extends FileEscandallosState {
  final List<CocktailRecipe> recipes;

  const FileEscandallosUploadSuccess(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class FileEscandallosUploadFailure extends FileEscandallosState {
  final String error;

  const FileEscandallosUploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
