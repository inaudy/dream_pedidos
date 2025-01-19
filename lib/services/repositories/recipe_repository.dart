import 'package:dream_pedidos/models/cocktail_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RecipeRepository {
  late Database _database;

  Future<void> initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cocktails.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cocktails (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          );
        ''');

        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cocktail_name TEXT NOT NULL,
            product_stock_name TEXT NOT NULL,
            size REAL NOT NULL,
            FOREIGN KEY (cocktail_name) REFERENCES cocktails (name) ON DELETE CASCADE
          );
        ''');
      },
    );
  }

  /// Add a new cocktail
  Future<void> addCocktail(Cocktail cocktail) async {
    // Insert cocktail name into the cocktails table
    await _database.insert(
      'cocktails',
      cocktail.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert each product into the recipes table
    for (var entry in cocktail.recipe.entries) {
      await _database.insert('recipes', {
        'cocktail_name': cocktail.name,
        'product_stock_name': entry.key,
        'size': entry.value,
      });
    }
  }

  /// Get a cocktail by name
  Future<Cocktail?> getCocktailByName(String cocktailName) async {
    final cocktailRows = await _database.query(
      'cocktails',
      where: 'name = ?',
      whereArgs: [cocktailName],
    );

    if (cocktailRows.isEmpty) return null;

    final recipeRows = await _database.query(
      'recipes',
      where: 'cocktail_name = ?',
      whereArgs: [cocktailName],
    );

    return Cocktail.fromMap(cocktailRows.first, recipeRows);
  }

  /// Get all cocktails
  Future<List<Cocktail>> getAllCocktails() async {
    final cocktailRows = await _database.query('cocktails');

    final cocktails = <Cocktail>[];
    for (var cocktailRow in cocktailRows) {
      final cocktailName = cocktailRow['name'] as String;

      final recipeRows = await _database.query(
        'recipes',
        where: 'cocktail_name = ?',
        whereArgs: [cocktailName],
      );

      cocktails.add(Cocktail.fromMap(cocktailRow, recipeRows));
    }

    return cocktails;
  }

  /// Update a cocktail
  Future<void> updateCocktail(Cocktail cocktail) async {
    await _database.update(
      'cocktails',
      cocktail.toMap(),
      where: 'name = ?',
      whereArgs: [cocktail.name],
    );

    // Delete old recipe entries
    await _database.delete(
      'recipes',
      where: 'cocktail_name = ?',
      whereArgs: [cocktail.name],
    );

    // Insert updated recipe entries
    for (var entry in cocktail.recipe.entries) {
      await _database.insert('recipes', {
        'cocktail_name': cocktail.name,
        'product_stock_name': entry.key,
        'size': entry.value,
      });
    }
  }

  /// Delete a cocktail
  Future<void> deleteCocktail(String cocktailName) async {
    await _database.delete(
      'cocktails',
      where: 'name = ?',
      whereArgs: [cocktailName],
    );
  }
}
