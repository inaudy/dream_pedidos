/*import 'package:dream_pedidos/models/conversion.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // For getting the database path

class ConversionRepository {
  static Database? _database;

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    // If the database doesn't exist, create it
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stock_database.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE conversions(id INTEGER PRIMARY KEY AUTOINCREMENT, item_name TEXT, conversion_size REAL)',
        );
      },
      version: 1,
    );
  }

  // Insert a new conversion into the database
  Future<void> insertConversion(Conversion conversion) async {
    final db = await database;
    await db.insert(
      'conversions',
      conversion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing conversion
  Future<void> updateConversion(Conversion conversion) async {
    final db = await database;
    await db.update(
      'conversions',
      conversion.toMap(),
      where: 'id = ?',
    );
  }

  // Delete a conversion by item name
  Future<void> deleteConversion(String itemName) async {
    final db = await database;
    await db.delete(
      'conversions',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }

  Future<void> addConversionItems(List<Conversion> items) async {
    final db = await database;
    // Start a batch operation for inserting items into the conversion table.
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'conversions',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Get all conversions
  Future<List<Conversion>> getAllConversions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('conversions');

    return List.generate(maps.length, (i) {
      return Conversion.fromMap(maps[i]);
    });
  }

  // Get the conversion size for a specific item by name
  Future<Conversion?> getConversionByItemName(String itemName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversions',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );

    if (maps.isNotEmpty) {
      return Conversion.fromMap(maps.first);
    }
    return null; // Return null if the item is not found
  }
}
*/