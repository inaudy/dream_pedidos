import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/models/stock_item.dart';

class StockRepository {
  static final StockRepository _instance = StockRepository._internal();

  factory StockRepository() => _instance;

  static Database? _database;

  StockRepository._internal();

  Future<Database> get database async {
    print('getdatabase');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stock_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE stock (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            actual_stock INTEGER NOT NULL,
            minimum_level INTEGER NOT NULL,
            maximum_level INTEGER NOT NULL,
            categorie TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert a single stock item into the database.
  Future<int> addStockItem(StockItem item) async {
    final db = await database;
    return await db.insert(
      'stock',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple stock items at once.
  Future<void> addStockItems(List<StockItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'stock',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieve all stock items from the database.
  Future<List<StockItem>> getAllStockItems() async {
    final db = await database;
    final result = await db.query('stock');

    return result.map((map) => StockItem.fromMap(map)).toList();
  }

  /// Update stock based on sales volume.
  Future<void> bulkUpdateStock(List<Map<String, dynamic>> salesData) async {
    final db = await database;

    await db.transaction((txn) async {
      for (final sale in salesData) {
        await txn.rawUpdate(
          '''
          UPDATE stock
          SET actual_stock = actual_stock - ?
          WHERE item_name = ?
          ''',
          [sale['sales_volume'], sale['item_name']],
        );
      }
    });
  }

  /// Update a stock item.
  Future<int> updateStockItem(StockItem item) async {
    final db = await database;
    return await db.update(
      'stock',
      item.toMap(),
      where: 'item_name = ?',
      whereArgs: [item.itemName],
    );
  }

  /// Delete a specific stock item by name.
  Future<int> deleteStockItem(String itemName) async {
    final db = await database;
    return await db.delete(
      'stock',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }

  /// Delete all stock items.
  Future<void> deleteAllStockItems() async {
    final db = await database;
    await db.delete('stock');
  }
}
