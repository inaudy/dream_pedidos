import 'package:dream_pedidos/presentation/blocs/recipe_parser_bloc/recipe_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/refill_history_bloc/refill_history_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_sync_bloc/stock_sync_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_parser_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/item_selection_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/pos_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/stock_search_cubit.dart';
import 'package:dream_pedidos/presentation/pages/home.dart';
import 'package:dream_pedidos/data/datasources/local/recipe_database.dart';
import 'package:dream_pedidos/data/datasources/local/stock_database.dart';
import 'package:dream_pedidos/presentation/pages/pos_selection_page.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import FFI SQLite
// Import SQLite3 FFI
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

StockDatabase createDatabaseForPos(PosType pos) {
  switch (pos) {
    case PosType.restaurant:
      return StockDatabase(dbName: 'restaurant.db');
    case PosType.beachClub:
      return StockDatabase(dbName: 'beach_club.db');
    case PosType.bar:
      return StockDatabase(dbName: 'bar.db');
    case PosType.cafeDelMar:
      return StockDatabase(dbName: 'cafedelmar.db');
    case PosType.santaRosa:
      return StockDatabase(dbName: 'santarosa.db');
  }
}

RecipeDatabase createRecipeDatabaseForPos(PosType pos) {
  switch (pos) {
    case PosType.restaurant:
      return RecipeDatabase(
          dbName: 'restaurant_recipes.db'); // note the "_recipes"
    case PosType.beachClub:
      return RecipeDatabase(dbName: 'beach_club_recipes.db');
    case PosType.bar:
      return RecipeDatabase(dbName: 'bar_recipes.db');
    case PosType.cafeDelMar:
      return RecipeDatabase(dbName: 'cafedelmar_recipes.db');
    case PosType.santaRosa:
      return RecipeDatabase(dbName: 'santarosa_recipes.db');
  }
}

void main() {
  // ✅ Initialize FFI SQLite for Windows, macOS, and Linux
  //sqfliteFfiInit();
  //databaseFactory = databaseFactoryFfi;
  runApp(
    BlocProvider(
      create: (_) => PosSelectionCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pedidos Tigotan',
        theme: ThemeData(primarySwatch: Colors.red),
        home: const PosSelectionPage(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final PosType selectedPos;
  const MyApp({super.key, required this.selectedPos});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosSelectionCubit, PosType>(
      builder: (context, pos) {
        final repository = createDatabaseForPos(pos);
        final recipeDatabase = createRecipeDatabaseForPos(pos);

        return MultiBlocProvider(
          key: ValueKey(pos),
          providers: [
            BlocProvider<StockManagementBloc>(
              create: (context) {
                final bloc = StockManagementBloc(repository, posKey: pos.name);
                bloc.add(LoadStockEvent());
                return bloc;
              },
            ),

            BlocProvider<FileStockBloc>(
              create: (context) {
                return FileStockBloc(
                    repository, context.read<StockManagementBloc>());
              },
            ),

            BlocProvider<StockSyncBloc>(
              create: (context) {
                return StockSyncBloc(
                    recipeRepository: recipeDatabase,
                    posKey: pos.name,
                    repository,
                    context.read<StockManagementBloc>());
              },
            ),
            // POS-dependent RefillHistoryBloc.
            BlocProvider<RefillHistoryBloc>(
              create: (context) {
                return RefillHistoryBloc(
                    repository, context.read<StockManagementBloc>());
              },
            ),
            BlocProvider<RecipeParserBloc>(
              create: (context) => RecipeParserBloc(
                  RecipeDatabase(dbName: recipeDatabase.dbName)),
            ),
            BlocProvider<SalesParserBloc>(
              create: (context) => SalesParserBloc(
                  context.read<PosSelectionCubit>(), recipeDatabase),
            ),
            BlocProvider<BottomNavcubit>(
              create: (_) => BottomNavcubit(),
            ),
            BlocProvider<StockSearchCubit>(
              create: (_) => StockSearchCubit(),
            ),
            // Provide Item Selection cubit.
            BlocProvider<ItemSelectionCubit>(
              create: (_) => ItemSelectionCubit(),
            ),
          ],
          child: MaterialApp(
            title: 'Pedidos Tigotan',
            theme: ThemeData(primarySwatch: Colors.red),
            // Pass the repository (for display purposes) to your Home page.
            home: HomePage(stockRepository: repository),
          ),
        );
      },
    );
  }
}
