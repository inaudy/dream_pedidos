import 'dart:io';
import 'package:dream_pedidos/models/recipe_model.dart';
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
    Map<String, Map<String, dynamic>> salesMap = {};

    for (var data in salesData) {
      if (salesMap.containsKey(data.itemName.toUpperCase())) {
        salesMap[data.itemName.toUpperCase()]!['salesVolume'] +=
            data.salesVolume;

        if (data.date.isAfter(salesMap[data.itemName.toUpperCase()]!['date'])) {
          salesMap[data.itemName.toUpperCase()]!['date'] = data.date;
        }
      } else {
        salesMap[data.itemName.toUpperCase()] = {
          'salesVolume': data.salesVolume,
          'date': data.date,
        };
      }
    }

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

  /// Parse cocktail recipes file
  static Future<List<CocktailRecipe>> parseCocktailRecipeFile(
      String filePath) async {
    final file = File(filePath);
    final extension = file.path.split('.').last.toLowerCase();

    if (extension == 'xlsx') {
      return await XLSXParser.parseCocktailRecipes(file);
    } else {
      throw Exception('Unsupported file type: $extension');
    }
  }
}
