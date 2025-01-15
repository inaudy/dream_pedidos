import 'dart:io';
import 'package:dream_pedidos/models/stock_item.dart';
import '/models/sales_data.dart';
import 'xlsx_parser.dart';

class FileParser {
  /// Parse the file based on its extension (CSV or XLSX).
  static Future<List<SalesData>> parseFile(String filePath) async {
    final file = File(filePath);
    final extension = file.path.split('.').last.toLowerCase();

    if (extension == 'xlsx') {
      return await XLSXParser.parseSalesXLSX(file);
    } else {
      throw Exception('Unsupported file type: $extension');
    }
  }

  static List<SalesData> sumSales(List<SalesData> salesData) {
    // Step 1: Create a Map to store the summed sales and the most recent date by itemName
    Map<String, Map<String, dynamic>> salesMap = {};

    for (var data in salesData) {
      if (salesMap.containsKey(data.itemName)) {
        // Update the sales volume
        salesMap[data.itemName]!['salesVolume'] += data.salesVolume;

        // Keep the most recent date
        if (data.date.isAfter(salesMap[data.itemName]!['date'])) {
          salesMap[data.itemName]!['date'] = data.date;
        }
      } else {
        // Add new item with salesVolume and date
        salesMap[data.itemName] = {
          'salesVolume': data.salesVolume,
          'date': data.date,
        };
      }
    }

    // Step 2: Convert the map back to a list of SalesData
    return salesMap.entries.map((entry) {
      return SalesData(
        itemName: entry.key,
        salesVolume: entry.value['salesVolume'] as double,
        date: entry.value['date'] as DateTime,
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
