import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/models/recipe_model.dart';
import 'package:dream_pedidos/services/repositories/cocktail_recipe_repository.dart';
import 'package:dream_pedidos/utils/event_bus.dart';
import 'package:equatable/equatable.dart';
import '../../utils/file_parser.dart';

part 'file_escandallos_event.dart';
part 'file_escandallos_state.dart';

class FileEscandallosBloc
    extends Bloc<FileEscandallosEvent, FileEscandallosState> {
  final CocktailRecipeRepository _cocktailRecipeRepository;

  FileEscandallosBloc(this._cocktailRecipeRepository)
      : super(FileEscandallosInitial()) {
    on<FileEscandallosUploadEvent>((event, emit) async {
      emit(FileEscandallosLoading());
      try {
        // Parse the cocktail recipe file
        final cocktailRecipeList =
            await FileParser.parseCocktailRecipeFile(event.filePath);

        // Add the parsed recipes to the database
        await _cocktailRecipeRepository.addCocktailRecipes(cocktailRecipeList);

        emit(FileEscandallosUploadSuccess(cocktailRecipeList));
        eventBus.emit('recipes_updated');
      } catch (e) {
        emit(FileEscandallosUploadFailure(e.toString()));
      }
    });
  }
}
