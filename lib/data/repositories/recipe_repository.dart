import 'package:dream_pedidos/data/models/recipe_model.dart';

abstract class CocktailRecipeRepository {
  /// Adds a single cocktail recipe to the data source
  Future<int> addCocktailRecipe(CocktailRecipe recipe);

  /// Adds multiple cocktail recipes to the data source
  Future<void> addCocktailRecipes(List<CocktailRecipe> recipes);

  /// Retrieves all cocktail recipes from the data source
  Future<List<CocktailRecipe>> getAllCocktailRecipes();

  /// Retrieves the ingredients for a specific cocktail
  Future<List<CocktailRecipe>> getIngredientsByCocktail(String itemName);

  /// Deletes all recipes for a specific cocktail
  Future<void> deleteCocktail(String itemName);

  /// Deletes all cocktail recipes from the data source
  Future<void> deleteAllCocktailRecipes();

  /// Updates an existing cocktail recipe
  Future<int> updateCocktailRecipe(CocktailRecipe recipe);
}
