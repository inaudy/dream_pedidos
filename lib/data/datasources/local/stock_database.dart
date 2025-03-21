// Move this file to: lib/data/sources/local/stock_database.dart
import 'package:dream_pedidos/data/models/refill_history_item.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/stock_item.dart';

class StockDatabase implements StockRepository {
  final String dbName;
  Database? _database;

  StockDatabase({required this.dbName});

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
            ean_code TEXT,
            error_percentage INTEGER DEFAULT 0
          )
          ''',
          '''
          CREATE TABLE refill_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            refill_quantity REAL NOT NULL,
            error_percentage REAL NOT NULL DEFAULT 0,
            refill_date TEXT NOT NULL,
            FOREIGN KEY (item_name) REFERENCES stock(item_name) ON DELETE CASCADE
          )
          '''
        ];

        for (var query in tableDefinitions) {
          await db.execute(query);
        }
      },
    );
  }

  Future<void> printAllStockItems() async {
    final stockItems = await getAllStockItems();
    print("---- Stock Table ----");
    for (var item in stockItems) {
      // Adjust the properties according to your StockItem model.
      print("Name: ${item.itemName}, Actual Stock: ${item.actualStock}, ");
    }
  }

  @override
  Future<void> resetStockFromBackup() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
      UPDATE stock 
      SET actual_stock = maximum_level
    ''');
      /*await txn.execute('DELETE FROM stock');
      await txn.execute('''
        INSERT INTO stock (item_name, actual_stock, minimum_level, maximum_level, category, traspaso, ean_code)
        SELECT item_name, actual_stock, minimum_level, maximum_level, category, traspaso, ean_code, error_percentage FROM stock_backup
      ''');*/
    });
  }

  // 🔹 Save a refill entry to the history table
  @override
  Future<void> saveRefillHistory(
      String itemName, double adjustedRefill, double errorPercentage) async {
    final db = await database;
    await db.insert(
      'refill_history',
      {
        'item_name': itemName,
        'refill_quantity': adjustedRefill,
        'error_percentage': errorPercentage,
        'refill_date': DateTime.now().toIso8601String(),
      },
    );
  }

// 🔹 Get all refill history
  @override
  Future<List<RefillHistoryItem>> getRefillHistory() async {
    final db = await database;
    final result =
        await db.query('refill_history', orderBy: 'refill_date DESC');
    return result.map((map) => RefillHistoryItem.fromMap(map)).toList();
  }

  @override
  Future<void> revertRefill(int refillId) async {
    final db = await database;

    // Get refill data including error_percentage.
    final result = await db
        .query('refill_history', where: 'id = ?', whereArgs: [refillId]);

    if (result.isNotEmpty) {
      final itemName = result.first['item_name'] as String;
      final adjustedRefill = result.first['refill_quantity'] as double;
      final errorPercentage =
          result.first['error_percentage'] as double? ?? 0.0;

      // Calculate raw refill amount.
      final rawRefill = adjustedRefill / (1 + errorPercentage / 100);

      // Restore stock by subtracting the raw refill.
      await db.rawUpdate(
        'UPDATE stock SET actual_stock = actual_stock - ? WHERE item_name = ?',
        [rawRefill, itemName],
      );

      // Delete the history entry.
      await db.delete('refill_history', where: 'id = ?', whereArgs: [refillId]);
    }
  }

  @override
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
    /* await db.execute('DELETE FROM stock_backup');
    await db.execute('''
      INSERT INTO stock_backup
      SELECT * FROM stock
    ''');*/
  }

  @override
  Future<List<StockItem>> getAllStockItems() async {
    final db = await database;
    final result = await db.query('stock');
    return result.map((map) => StockItem.fromMap(map)).toList();
  }

  /// Get error percentage for a specific item (returns 0 if no error is assigned)
  Future<int> getErrorPercentage(String itemName) async {
    final db = await database;
    final result = await db.query(
      'stock',
      columns: ['error_percentage'],
      where: 'item_name = ?',
      whereArgs: [itemName],
    );

    if (result.isNotEmpty) {
      return (result.first['error_percentage'] as num?)?.toInt() ?? 0;
    }
    return 0; // Default is 0% error if not found
  }

  @override
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

  /*@override
  Future<void> bulkUpdateStock(List<Map<String, dynamic>> salesData) async {
    final db = await database;

    // Aggregate sales data by item name
    final Map<String, double> aggregatedData = {};

    for (final sale in salesData) {
      final itemName = sale['item_name'];
      final volume = sale['sales_volume'];

      if (aggregatedData.containsKey(itemName)) {
        aggregatedData[itemName] = aggregatedData[itemName]! + volume;
      } else {
        aggregatedData[itemName] = volume;
      }
    }

    // Run the batch update with aggregated data
    await db.transaction((txn) async {
      final batch = txn.batch();
      aggregatedData.forEach((itemName, totalVolume) {
        print('Updating $itemName with volume $totalVolume');
        batch.rawUpdate(
          '''
        UPDATE stock
        SET actual_stock = actual_stock - ?
        WHERE item_name = ?
        ''',
          [totalVolume, itemName],
        );
      });

      await batch.commit(noResult: true);
    });
  }*/

  @override
  Future<int> updateStockItem(StockItem item) async {
    final db = await database;
    return await db.update(
      'stock',
      item.toMap(),
      where: 'item_name = ?',
      whereArgs: [item.itemName], // Ensure correct WHERE clause
    );
  }
}
