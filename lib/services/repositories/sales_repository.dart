import '/models/sales_data.dart';
import '/utils/database_helper.dart';

class SalesRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertSalesData(SalesData data) async {
    final db = await _dbHelper.database;
    await db.insert('sales_data', data.toMap());
  }

  Future<List<SalesData>> fetchSalesData(int salesPointId, String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sales_data',
      where: 'sales_point_id = ? AND date = ?',
      whereArgs: [salesPointId, date],
    );

    return List.generate(maps.length, (i) => SalesData.fromMap(maps[i]));
  }
}
