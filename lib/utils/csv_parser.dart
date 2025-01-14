import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dream_pedidos/models/sales_data.dart';

class CSVParser {
  /// Parse the CSV file and return a list of SalesData.
  static Future<List<SalesData>> parseCSV(File file) async {
    final input = await file.readAsString();
    final rows = const CsvToListConverter().convert(input);

    // Assuming the first row contains headers
    return rows.skip(1).map((row) {
      return SalesData(
        date: row[0] as DateTime,
        itemName: row[2] as String,
        salesVolume: row[17] as double,
      );
    }).toList();
  }
}
