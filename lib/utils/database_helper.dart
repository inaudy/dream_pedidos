import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sales_management.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sales_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            location TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE stock (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sales_point_id INTEGER,
            item_name TEXT NOT NULL,
            starting_stock INTEGER,
            actual_stock INTEGER,
            minimum_level INTEGER,
            maximum_level INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE sales_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sales_point_id INTEGER,
            item_name TEXT NOT NULL,
            sales_volume INTEGER,
            date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE refill_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sales_point_id INTEGER,
            item_name TEXT NOT NULL,
            refill_amount INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }
}
