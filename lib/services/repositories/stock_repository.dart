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

        // Create backup stock table
        await db.execute('''
          CREATE TABLE stock_backup (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            actual_stock REAL NOT NULL,
            minimum_level INTREALEGER NOT NULL,
            maximum_level REAL NOT NULL,
            category TEXT NOT NULL,
            traspaso TEXT
          )
        ''');
      },
    );
  }

  Future<void> resetStockFromBackup() async {
    final db = await database;

    await db.transaction((txn) async {
      // Clear current stock table
      await txn.delete('stock');

      // Restore from backup
      final backupItems = await txn.query('stock_backup');
      for (final item in backupItems) {
        await txn.insert(
          'stock',
          item,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
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

    // Start a batch operation for inserting items into the stock table.
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'stock',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    // Back up the stock table into the stock_backup table in a batch.
    final backupItems = await db.query('stock');
    if (backupItems.isNotEmpty) {
      final backupBatch = db.batch();
      for (final item in backupItems) {
        backupBatch.insert(
          'stock_backup',
          item,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await backupBatch.commit(noResult: true);
    }
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
