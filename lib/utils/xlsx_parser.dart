import 'dart:io';
import 'package:dream_pedidos/models/stock_item.dart';
import 'package:excel/excel.dart';
import '/models/sales_data.dart';
import 'package:intl/intl.dart';

class XLSXParser {
  /// Parse the XLSX file and return a list of SalesData.
  static Future<List<SalesData>> parseSalesXLSX(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Get the first sheet
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No data found in the XLSX file');
    }

    // Skip the first row (headers) and map to SalesData model
    return sheet.rows.skip(1).map((row) {
      return SalesData(
        date: _parseDate(row[0]?.value), // Updated for dynamic input
        itemName: row[2]?.value.toString() ?? '',
        salesVolume: double.tryParse(row[17]?.value.toString() ?? '0') ?? 0,
      );
    }).toList();
  }

  static Future<List<StockItem>> parseStockXLSX(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Get the first sheet
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No data found in the XLSX file');
    }

    // Skip the header row and map each row to a StockItem
    return sheet.rows.skip(1).map((row) {
      return StockItem(
          itemName: row[0]?.value.toString() ?? '',
          actualStock: int.tryParse(row[1]?.value.toString() ?? '0') ?? 0,
          minimumLevel: int.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
          maximumLevel: int.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
          categorie: row[4]?.value.toString() ?? '0');
    }).toList();
  }

  /// Parse Excel date formats or strings into DateTime.
  static DateTime _parseDate(dynamic value) {
    // Check if the value is a TextCellValue and extract the string
    if (value is TextCellValue) {
      value = value.value;
    }

    // Now handle the value as a String
    String date = value.toString();

    if (date is String) {
      try {
        // Adjust the DateFormat to match the MM/dd/yyyy HH:mm format
        return DateFormat("MM/dd/yyyy HH:mm")
            .parseStrict(date); // Adjust format as needed
      } catch (e) {
        // Handle other formats or fallback
        return DateTime.now();
      }
    } else if (value is int) {
      // Excel serial date number
      return DateTime(1900).add(Duration(days: value - 2));
    } else if (value is double) {
      // Excel serial date as a double
      return DateTime(1900)
          .add(Duration(milliseconds: (value * 86400000).toInt() - 86400000));
    }
    // Default to current date if unable to parse
    return DateTime.now();
  }
}
