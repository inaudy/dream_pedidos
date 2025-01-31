import 'package:dream_pedidos/data/repositories/recipe_repository.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/presentation/blocs/recipe_parser_bloc/recipe_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_sync_bloc/stock_sync_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/item_selection_cubit.dart';
import 'package:dream_pedidos/presentation/blocs/stock_parser_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/stock_search_cubit.dart';
import 'package:dream_pedidos/presentation/pages/home.dart';
import 'package:dream_pedidos/data/datasources/local/recipe_database.dart';
import 'package:dream_pedidos/data/datasources/local/stock_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final StockRepository stockRepository = StockDatabase();
  final CocktailRecipeRepository cocktailRecipeRepository = RecipeDatabase();
  runApp(MyApp(
      stockRepository: stockRepository,
      cocktailRecipeRepository: cocktailRecipeRepository));
}

class MyApp extends StatelessWidget {
  final StockRepository stockRepository;
  final CocktailRecipeRepository cocktailRecipeRepository;
  const MyApp(
      {super.key,
      required this.stockRepository,
      required this.cocktailRecipeRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos Tigotan',
      theme: ThemeData(primarySwatch: Colors.red),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => FileStockBloc(
                  stockRepository, StockManagementBloc(stockRepository))),
          BlocProvider(
              create: (context) => RecipeParserBloc(cocktailRecipeRepository)),
          BlocProvider(create: (context) => StockSearchCubit()),
          BlocProvider(
            create: (context) => StockManagementBloc(stockRepository)
              ..add(LoadStockEvent()), // Load stock on startup
          ),
          BlocProvider(
            create: (context) => StockSyncBloc(
                stockRepository, StockManagementBloc(stockRepository)),
          ),
          BlocProvider(create: (context) => SalesParserBloc()),
          BlocProvider(create: (context) => ItemSelectionCubit()),
          BlocProvider(create: (context) => BottomNavcubit()),
        ],
        child: HomePage(
          stockRepository: stockRepository,
        ),
      ),
    );
  }
}
