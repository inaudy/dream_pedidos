import 'dart:io';
import 'package:dream_pedidos/models/conversion.dart';
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

  static Future<List<Conversion>> parseConversion(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Get the first sheet
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No data found in the XLSX file');
    }

    // Skip the first row (headers) and map to SalesData model
    return sheet.rows.skip(1).map((row) {
      return Conversion(
        itemName: row[0]?.value.toString() ?? '',
        conversionSize: double.tryParse(row[1]?.value.toString() ?? '0') ?? 0,
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
        actualStock: double.tryParse(row[1]?.value.toString() ?? '0') ?? 0,
        minimumLevel: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
        maximumLevel: double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
        category: row[4]?.value.toString() ?? '0',
        traspaso: row[5]?.value.toString() ?? '',
      );
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

    try {
      print(DateFormat("dd/MM/yyyy HH:mm").parse(date));
      // Adjust the DateFormat to match the MM/dd/yyyy HH:mm format
      return DateFormat("dd/MM/yyyy HH:mm")
          .parse(date); // Adjust format as needed
    } catch (e) {
      // Handle other formats or fallback
      print(e);
      return DateTime.parse(date);
    }
    // Default to current date if unable to parse
  }
}
