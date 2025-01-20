import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/models/stock_item.dart';

class StockRepository {
  static final StockRepository _instance = StockRepository._internal();

  factory StockRepository() => _instance;

  static Database? _database;

  StockRepository._internal();

  Future<Database> get database async {
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
            actual_stock REAL NOT NULL,
            minimum_level REAL NOT NULL,
            maximum_level REAL NOT NULL,
            category TEXT NOT NULL,
            traspaso TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE stock_backup (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            actual_stock REAL NOT NULL,
            minimum_level REAL NOT NULL,
            maximum_level REAL NOT NULL,
            category TEXT NOT NULL,
            traspaso TEXT
          )
        ''');
      },
    );
  }

  /// Reset stock from the backup table
  Future<void> resetStockFromBackup() async {
    final db = await database;

    await db.transaction((txn) async {
      // Clear the current stock table
      await txn.delete('stock');

      // Copy all data from stock_backup to stock
      await txn.rawInsert('''
      INSERT INTO stock (item_name, actual_stock, minimum_level, maximum_level, category, traspaso)
      SELECT item_name, actual_stock, minimum_level, maximum_level, category, traspaso
      FROM stock_backup
    ''');
    });
  }

  /// Add a single stock item
  Future<int> addStockItem(StockItem item) async {
    final db = await database;
    return await db.insert(
      'stock',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Add multiple stock items in bulk
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

    final backupBatch = db.batch();
    final backupItems = await db.query('stock');
    for (final item in backupItems) {
      backupBatch.insert(
        'stock_backup',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await backupBatch.commit(noResult: true);
  }

  /// Retrieve all stock items
  Future<List<StockItem>> getAllStockItems() async {
    final db = await database;
    final result = await db.query('stock');

    return result.map((map) => StockItem.fromMap(map)).toList();
  }

  /// Bulk update stock based on sales data
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

  /// Update a single stock item
  Future<int> updateStockItem(StockItem item) async {
    final db = await database;
    return await db.update(
      'stock',
      item.toMap(),
      where: 'item_name = ?',
      whereArgs: [item.itemName],
    );
  }

  /// Delete a single stock item by name
  Future<int> deleteStockItem(String itemName) async {
    final db = await database;
    return await db.delete(
      'stock',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }

  /// Delete all stock items
  Future<void> deleteAllStockItems() async {
    final db = await database;
    await db.delete('stock');
  }
}
