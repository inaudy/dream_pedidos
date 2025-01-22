part of 'recipe_parser_bloc.dart';

abstract class RecipeParserState extends Equatable {
  const RecipeParserState();

  @override
  List<Object?> get props => [];
}

class RecipeParserInitial extends RecipeParserState {}

class RecipeParserLoading extends RecipeParserState {}

class RecipeParserSuccess extends RecipeParserState {
  final List<CocktailRecipe> recipes;

  const RecipeParserSuccess(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipeParserFailure extends RecipeParserState {
  final String error;

  const RecipeParserFailure(this.error);

  @override
  List<Object?> get props => [error];
}
