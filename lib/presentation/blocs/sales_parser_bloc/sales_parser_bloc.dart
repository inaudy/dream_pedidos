import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/datasources/external/file_parser.dart';
import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:dream_pedidos/presentation/cubit/pos_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dream_pedidos/data/repositories/recipe_repository.dart';
part 'sales_parser_event.dart';
part 'sales_parser_state.dart';

class SalesParserBloc extends Bloc<SalesParserEvent, SalesParserState> {
  final PosSelectionCubit posSelectionCubit;
  final CocktailRecipeRepository recipeRepository;

  SalesParserBloc(this.posSelectionCubit, this.recipeRepository)
      : super(SalesParserInitial()) {
    on<SalesParserUploadEvent>(_onUploadFile);
    on<SalesParserPickFileEvent>(_onPickFile);
  }

  Future<void> _onPickFile(
      SalesParserPickFileEvent event, Emitter<SalesParserState> emit) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        add(SalesParserUploadEvent(filePath));
      } else {
        emit(SalesParserFailure("No file selected"));
      }
    } catch (e) {
      emit(SalesParserFailure("Failed to pick a file: ${e.toString()}"));
    }
  }

  Future<void> _onUploadFile(
      SalesParserUploadEvent event, Emitter<SalesParserState> emit) async {
    emit(SalesParserLoading());
    final selectedPos = posSelectionCubit.state;
    final file = File(event.filePath);
    try {
      final salesDataList = await FileParser.parseFile(event.filePath);
      late List<SalesData> filteredSalesData;

      // Filtering logic based on the selected POS.
      if (selectedPos == PosType.restaurant) {
        // Check for too many sales between 12 and 16 (indicating BeachClub sales).
        final poolSales = salesDataList.where((sale) {
          final hour = sale.date.hour;
          return hour >= 12 && hour < 16;
        }).toList();
        if (poolSales.length > 10) {
          emit(SalesParserFailure(
              "Las ventas son del Beach Club y estas en el POS RESTAURANTE, cambia de POS o sube el archivo correcto"));
          return;
        }

        // Filter for yesterday's sales (normalized without time).
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final normalizedYesterday =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        filteredSalesData = salesDataList.where((sale) {
          final saleDateNormalized =
              DateTime(sale.date.year, sale.date.month, sale.date.day);
          return saleDateNormalized == normalizedYesterday;
        }).toList();
        if (filteredSalesData.isEmpty) {
          emit(SalesParserFailure('No hay ventas de ayer'));
          return;
        }
      }

      if (selectedPos == PosType.beachClub) {
        // Check for insufficient sales between 12 and 16 (indicating Restaurant sales).
        final poolSales = salesDataList.where((sale) {
          final hour = sale.date.hour;
          return hour >= 12 && hour < 16;
        }).toList();
        if (poolSales.length <= 10) {
          emit(SalesParserFailure(
              "Las ventas son del Restaurante y estas en el POS BEACH CLUB, cambia de POS o sube el archivo correcto"));
          return;
        }
        final now = DateTime.now();
        final todayAt16 = DateTime(now.year, now.month, now.day, 16, 00);
        final yesterdayAt16 = todayAt16.subtract(const Duration(days: 1));
        filteredSalesData = salesDataList
            .where((sale) =>
                (!sale.date.isBefore(yesterdayAt16)) &&
                sale.date.isBefore(todayAt16))
            .toList();
        if (filteredSalesData.isEmpty) {
          emit(SalesParserFailure(
              'No hay ventas en el período de 16:00 a 15:59.'));
          return;
        }
      }

      // For other POS types, you can add additional filtering if needed.

      // For each sale in the filtered list, check for a cocktail recipe and convert if needed.
      final List<SalesData> convertedSalesData =
          await _convertSalesToIngredients(filteredSalesData);

      // Sum (aggregate) the converted sales so repeated items are merged.
      final summedSalesData = FileParser.sumSales(convertedSalesData);
      final sumventas = FileParser.sumSales(filteredSalesData);
      // Emit the final, aggregated sales data.
      emit(
          SalesParserSuccess(converted: summedSalesData, salesData: sumventas));

      if (Platform.isAndroid) {
        // Optionally, request storage permission and delete the file from Downloads.
        requestStoragePermission();
        print('Attempting to delete file at path: ${file.path}');
        final fileName = file.path.split('/').last;
        final originalFilePath = '/storage/emulated/0/Download/$fileName';
        final originalFile = File(originalFilePath);
        if (await originalFile.exists()) {
          await originalFile.delete();
        }
      }
    } catch (e) {
      emit(SalesParserFailure(e.toString()));
    }
  }

  /// For every sale, if a cocktail recipe exists, convert it into ingredient-level sales.
  /// Otherwise, leave the sale as is.
  Future<List<SalesData>> _convertSalesToIngredients(
      List<SalesData> sales) async {
    List<SalesData> result = [];
    for (final sale in sales) {
      // Check for a cocktail recipe.
      final cocktailRecipes =
          await recipeRepository.getIngredientsByCocktail(sale.itemName);
      if (cocktailRecipes.isNotEmpty) {
        // If a recipe exists, create a sale entry for each ingredient.
        for (final recipe in cocktailRecipes) {
          result.add(
            SalesData(
              itemName: recipe.ingredientName, // ingredient name
              salesVolume:
                  sale.salesVolume * recipe.quantity, // adjusted volume
              date: sale.date,
            ),
          );
        }
      } else {
        // No recipe: keep the original sale.
        result.add(sale);
      }
    }
    return result;
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isDenied ||
        await Permission.manageExternalStorage.isRestricted) {
      await Permission.manageExternalStorage.request();
    }
    if (await Permission.manageExternalStorage.isGranted) {
      print("Storage permission granted.");
    } else {
      print("Storage permission denied.");
    }
  }
}
