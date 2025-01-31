import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/datasources/external/file_parser.dart';
import 'package:dream_pedidos/data/models/recipe_model.dart';
import 'package:dream_pedidos/data/repositories/recipe_repository.dart';
import 'package:equatable/equatable.dart';
part 'recipe_parser_event.dart';
part 'recipe_parser_state.dart';

class RecipeParserBloc extends Bloc<RecipeParserEvent, RecipeParserState> {
  final CocktailRecipeRepository _cocktailRecipeRepository;

  RecipeParserBloc(this._cocktailRecipeRepository)
      : super(RecipeParserInitial()) {
    on<RecipeParserUploadEvent>((event, emit) async {
      emit(RecipeParserLoading());
      try {
        // Parse the cocktail RecipeParser file
        final cocktailRecipeList =
            await FileParser.parseCocktailRecipeFile(event.filePath);

        // Add the parsed recipes to the database
        await _cocktailRecipeRepository.addCocktailRecipes(cocktailRecipeList);

        emit(RecipeParserSuccess(cocktailRecipeList));
      } catch (e) {
        emit(RecipeParserFailure(e.toString()));
      }
    });
  }
}
