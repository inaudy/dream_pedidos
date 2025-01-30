import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock_item.dart';

class StockRepository {
  static final StockRepository _instance = StockRepository._internal();
  factory StockRepository() => _instance;

  Database? _database; // Nullable to avoid uninitialized access

  StockRepository._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stock_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        const tableDefinitions = [
          '''
          CREATE TABLE stock (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL UNIQUE,
            actual_stock REAL NOT NULL,
            minimum_level REAL NOT NULL,
            maximum_level REAL NOT NULL,
            category TEXT NOT NULL,
            traspaso TEXT,
            ean_code TEXT
          )
          ''',
          '''
          CREATE TABLE stock_backup (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL UNIQUE,
            actual_stock REAL NOT NULL,
            minimum_level REAL NOT NULL,
            maximum_level REAL NOT NULL,
            category TEXT NOT NULL,
            traspaso TEXT,
            ean_code TEXT
          )
          '''
        ];

        for (var query in tableDefinitions) {
          await db.execute(query);
        }
      },
    );
  }

  /// Resets stock by copying data from stock_backup
  Future<void> resetStockFromBackup() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('DELETE FROM stock');
      await txn.execute('''
        INSERT INTO stock (item_name, actual_stock, minimum_level, maximum_level, category, traspaso, ean_code)
        SELECT item_name, actual_stock, minimum_level, maximum_level, category, traspaso, ean_code FROM stock_backup
      ''');
    });
  }

  /// Debugging function to print all stock items
  Future<void> printAllStockItems() async {
    final db = await database;
    final result = await db.query('stock');

    if (result.isEmpty) {
      print('No data found in stock.');
    } else {
      for (var row in result) {
        print(row);
      }
    }
  }

  /// Inserts multiple stock items efficiently
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

    // Backup stock after bulk insert
    await db.execute('DELETE FROM stock_backup');
    await db.execute('''
      INSERT INTO stock_backup
      SELECT * FROM stock
    ''');
  }

  /// Retrieves all stock items
  Future<List<StockItem>> getAllStockItems() async {
    final db = await database;
    final result = await db.query('stock');
    return result.map((map) => StockItem.fromMap(map)).toList();
  }

  /// Updates stock in bulk using sales data
  Future<void> bulkUpdateStock(List<Map<String, dynamic>> salesData) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final sale in salesData) {
        batch.rawUpdate(
          '''
          UPDATE stock
          SET actual_stock = actual_stock - ?
          WHERE item_name = ?
          ''',
          [sale['sales_volume'], sale['item_name']],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Updates a single stock item
  Future<int> updateStockItem(StockItem item) async {
    final db = await database;
    return await db.update(
      'stock',
      item.toMap(),
      where: 'item_name = ?',
      whereArgs: [item.itemName],
    );
  }
}
