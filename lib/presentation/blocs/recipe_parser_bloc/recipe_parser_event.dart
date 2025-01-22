part of 'recipe_parser_bloc.dart';

abstract class RecipeParserEvent extends Equatable {
  const RecipeParserEvent();

  @override
  List<Object> get props => [];
}

class RecipeParserUploadEvent extends RecipeParserEvent {
  final String filePath;

  const RecipeParserUploadEvent(this.filePath);

  @override
  List<Object> get props => [filePath];
}
