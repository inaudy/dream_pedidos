import 'package:dream_pedidos/blocs/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/blocs/cubit/item_selection_cubit.dart';
import 'package:dream_pedidos/blocs/file_bloc/file_bloc.dart';
import 'package:dream_pedidos/blocs/file_bloc/file_escandallos_bloc.dart';
import 'package:dream_pedidos/blocs/file_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/presentation/pages/home.dart';
import 'package:dream_pedidos/services/repositories/cocktail_recipe_repository.dart';
import 'package:dream_pedidos/services/repositories/escandallo_repository.dart';
import 'package:dream_pedidos/services/repositories/stock_repository.dart';
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
            create: (context) =>
                FileEscandallosBloc(CocktailRecipeRepository()),
          ),
          BlocProvider(
            create: (context) =>
                StockBloc(StockRepository(), CocktailRecipeRepository()),
          ),
          BlocProvider(
            create: (context) => FileBloc(),
          ),
          BlocProvider(create: (context) => ItemSelectionCubit()),
          BlocProvider(create: (context) => BottomNavcubit())
        ],
        child: HomePage(),
      ),
    );
  }
}
