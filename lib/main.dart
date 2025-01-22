import 'package:dream_pedidos/presentation/blocs/recipe_parser_bloc/recipe_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/item_selection_cubit.dart';
import 'package:dream_pedidos/presentation/blocs/stock_parser_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/presentation/pages/home.dart';
import 'package:dream_pedidos/data/repositories/cocktail_recipe_repository.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos Tigotan',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FileStockBloc(StockRepository()),
          ),
          BlocProvider(
            create: (context) => RecipeParserBloc(CocktailRecipeRepository()),
          ),
          BlocProvider(
            create: (context) =>
                StockBloc(StockRepository(), CocktailRecipeRepository()),
          ),
          BlocProvider(
            create: (context) => SalesParserBloc(),
          ),
          BlocProvider(create: (context) => ItemSelectionCubit()),
          BlocProvider(create: (context) => BottomNavcubit())
        ],
        child: HomePage(),
      ),
    );
  }
}
