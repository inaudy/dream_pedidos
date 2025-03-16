import 'package:dream_pedidos/data/models/recipe_model.dart';
import 'package:dream_pedidos/data/repositories/recipe_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RecipeDatabase implements CocktailRecipeRepository {
  final String dbName;
  Database? _database;

  RecipeDatabase({required this.dbName});

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cocktail_recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            ingredient_name TEXT NOT NULL,
            quantity REAL NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<int> addCocktailRecipe(CocktailRecipe recipe) async {
    final db = await database;
    return await db.insert(
      'cocktail_recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> addCocktailRecipes(List<CocktailRecipe> recipes) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete all existing records from the table.
      await txn.delete('cocktail_recipes');
      // Create a batch for the insert operations.
      final batch = txn.batch();
      for (final recipe in recipes) {
        batch.insert(
          'cocktail_recipes',
          recipe.toMap(),
        );
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<List<CocktailRecipe>> getAllCocktailRecipes() async {
    final db = await database;
    final result = await db.query('cocktail_recipes');
    return result.map((map) => CocktailRecipe.fromMap(map)).toList();
  }

  @override
  Future<List<CocktailRecipe>> getIngredientsByCocktail(String itemName) async {
    final db = await database;
    final result = await db.query(
      'cocktail_recipes',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
    return result.map((map) => CocktailRecipe.fromMap(map)).toList();
  }

  @override
  Future<void> deleteCocktail(String itemName) async {
    final db = await database;
    await db.delete(
      'cocktail_recipes',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }

  @override
  Future<void> deleteAllCocktailRecipes() async {
    final db = await database;
    await db.delete('cocktail_recipes');
  }

  @override
  Future<int> updateCocktailRecipe(CocktailRecipe recipe) async {
    final db = await database;
    return await db.update(
      'cocktail_recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }
}
