import 'package:dream_pedidos/models/recipe_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CocktailRecipeRepository {
  static final CocktailRecipeRepository _instance =
      CocktailRecipeRepository._internal();

  factory CocktailRecipeRepository() => _instance;

  static Database? _database;

  CocktailRecipeRepository._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cocktail_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cocktail_recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,          -- e.g., 'Mojito'
            ingredient_name TEXT NOT NULL,    -- e.g., 'Rum'
            quantity REAL NOT NULL            -- e.g., 50 (for 50ml of Rum)
          )
        ''');
      },
    );
  }

  /// Add a single cocktail recipe
  Future<int> addCocktailRecipe(CocktailRecipe recipe) async {
    final db = await database;
    return await db.insert(
      'cocktail_recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Add multiple cocktail recipes
  Future<void> addCocktailRecipes(List<CocktailRecipe> recipes) async {
    final db = await database;

    final batch = db.batch();
    for (final recipe in recipes) {
      batch.insert(
        'cocktail_recipes',
        recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieve all cocktail recipes
  Future<List<CocktailRecipe>> getAllCocktailRecipes() async {
    final db = await database;
    final result = await db.query('cocktail_recipes');

    return result.map((map) => CocktailRecipe.fromMap(map)).toList();
  }

  /// Retrieve ingredients for a specific cocktail
  Future<List<CocktailRecipe>> getIngredientsByCocktail(String itemName) async {
    final db = await database;
    final result = await db.query(
      'cocktail_recipes',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );

    return result.map((map) => CocktailRecipe.fromMap(map)).toList();
  }

  /// Delete all recipes for a specific cocktail
  Future<void> deleteCocktail(String itemName) async {
    final db = await database;
    await db.delete(
      'cocktail_recipes',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }

  /// Delete all cocktail recipes
  Future<void> deleteAllCocktailRecipes() async {
    final db = await database;
    await db.delete('cocktail_recipes');
  }

  /// Update a cocktail recipe
  Future<int> updateCocktailRecipe(CocktailRecipe recipe) async {
    final db = await database;
    return await db.update(
      'cocktail_recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id], // Add 'id' to the CocktailRecipe model if needed
    );
  }
}
