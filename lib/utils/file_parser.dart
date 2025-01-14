import 'dart:io';
import 'package:dream_pedidos/models/stock_item.dart';

import '/models/sales_data.dart';
import 'csv_parser.dart';
import 'xlsx_parser.dart';

class FileParser {
  /// Parse the file based on its extension (CSV or XLSX).
  static Future<List<SalesData>> parseFile(String filePath) async {
    final file = File(filePath);
    final extension = file.path.split('.').last.toLowerCase();

    if (extension == 'csv') {
      return await CSVParser.parseCSV(file);
    } else if (extension == 'xlsx') {
      return await XLSXParser.parseSalesXLSX(file);
    } else {
      throw Exception('Unsupported file type: $extension');
    }
  }

  static List<SalesData> sumSales(List<SalesData> salesData) {
    // Step 1: Create a Map to store the summed sales by itemName
    Map<String, double> salesMap = {};

    for (var data in salesData) {
      if (salesMap.containsKey(data.itemName)) {
        // Add the sales volume if the item already exists in the map
        salesMap[data.itemName] = salesMap[data.itemName]! + data.salesVolume;
      } else {
        // Add the item to the map if it's not already there
        salesMap[data.itemName] = data.salesVolume;
      }
    }

    // Step 2: Convert the map back to a list of SalesData
    return salesMap.entries.map((entry) {
      return SalesData(
        itemName: entry.key,
        salesVolume: entry.value,
        date: DateTime.now(), // You can use a specific date here if needed
      );
    }).toList();
  }

  static Future<List<StockItem>> parseStockFile(String filePath) async {
    final file = File(filePath);
    final extension = file.path.split('.').last.toLowerCase();

    if (extension == 'xlsx') {
      return await XLSXParser.parseStockXLSX(file);
    } else {
      throw Exception('Unsupported file type: $extension');
    }
  }
}
