import 'dart:io';
import 'package:dream_pedidos/data/models/recipe_model.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import '../../models/sales_data.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class XLSXParser {
  static Future<List<SalesData>> parseSalesXLSX(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No data found in the XLSX file');
    }

    return sheet.rows.skip(1).map((row) {
      return SalesData(
        date: _parseDate(row[0]?.value),
        itemName: row[2]?.value.toString() ?? '',
        salesVolume: double.tryParse(row[17]?.value.toString() ?? '0') ?? 0,
      );
    }).toList();
  }

  /// Parse cocktail recipes from XLSX file
  static Future<List<CocktailRecipe>> parseCocktailRecipes(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No data found in the XLSX file');
    }

    return sheet.rows.skip(1).map((row) {
      return CocktailRecipe(
        itemName: row[0]?.value.toString() ?? '', // Cocktail name
        ingredientName: row[1]?.value.toString() ?? '', // Ingredient name
        quantity:
            double.tryParse(row[2]?.value.toString() ?? '0') ?? 0, // Quantity
      );
    }).toList();
  }

  static Future<List<StockItem>> parseStockXLSX(File file) async {
    final bytes = await file.readAsBytes();

    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No data found in the XLSX file');
    }

    return sheet.rows.skip(1).map((row) {
      return StockItem(
        itemName: row[0]?.value.toString() ?? '',
        actualStock: double.tryParse(row[1]?.value.toString() ?? '0') ?? 0,
        minimumLevel: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
        maximumLevel: double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
        category: row[4]?.value.toString() ?? '',
        traspaso: row[5]?.value.toString() ?? '',
        eanCode: row[6]?.value.toString() ?? '',
        errorPercentage: int.tryParse(row[7]?.value.toString() ?? '0') ?? 0,
      );
    }).toList();
  }

  static DateTime _parseDate(dynamic value) {
    if (value is TextCellValue) {
      value = value.value;
    }
    String date = value.toString();

    try {
      return DateFormat("dd/MM/yyyy HH:mm").parse(date);
    } catch (e) {
      return DateTime.parse(date);
    }
  }
}
