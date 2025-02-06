import 'package:dream_pedidos/data/repositories/recipe_repository.dart';
import 'package:dream_pedidos/presentation/blocs/recipe_parser_bloc/recipe_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/refill_history_bloc/refill_history_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_sync_bloc/stock_sync_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/item_selection_cubit.dart';
import 'package:dream_pedidos/presentation/blocs/stock_parser_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/pos_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/stock_search_cubit.dart';
import 'package:dream_pedidos/presentation/pages/home.dart';
import 'package:dream_pedidos/data/datasources/local/recipe_database.dart';
import 'package:dream_pedidos/data/datasources/local/stock_database.dart';
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
  }
}

void main() {
  runApp(
    // Wrap the entire app with providers that must be available globally.
    MultiBlocProvider(
      providers: [
        BlocProvider<PosSelectionCubit>(
          create: (_) => PosSelectionCubit(),
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CocktailRecipeRepository cocktailRecipeRepository = RecipeDatabase();
  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to listen to changes in the selected POS.
    return BlocBuilder<PosSelectionCubit, PosType>(
      builder: (context, pos) {
        // Create a new repository based on the currently selected POS.
        final repository = createDatabaseForPos(pos);
        // Use a ValueKey with the POS so that when pos changes,
        // the subtree (and its blocs) are rebuilt.
        return MultiBlocProvider(
          key: ValueKey(pos),
          providers: [
            // Create the POS-dependent StockManagementBloc.
            BlocProvider<StockManagementBloc>(
              create: (context) {
                final bloc = StockManagementBloc(repository, posKey: pos.name);
                bloc.add(LoadStockEvent());
                return bloc;
              },
            ),
            // POS-dependent FileStockBloc.
            BlocProvider<FileStockBloc>(
              create: (context) {
                return FileStockBloc(
                    repository, context.read<StockManagementBloc>());
              },
            ),
            // POS-dependent StockSyncBloc.
            BlocProvider<StockSyncBloc>(
              create: (context) {
                return StockSyncBloc(
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
            // Add any additional POS-dependent blocs here.
            // For example, if your RecipeParserBloc is also POS-dependent,
            // you could similarly reinitialize it here with a repository.
            BlocProvider<RecipeParserBloc>(
              create: (context) => RecipeParserBloc(RecipeDatabase()),
            ),
            BlocProvider<SalesParserBloc>(
              create: (context) => SalesParserBloc(),
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

  /*return MaterialApp(
      title: 'Pedidos Tigotan',
      theme: ThemeData(primarySwatch: Colors.red),
      home: MultiBlocProvider(
        providers: [
          
          // Now, using a Builder to access PosSelectionCubit, create the StockManagementBloc.
          BlocProvider<StockManagementBloc>(
            create: (context) {
              // Get the current POS.
              final pos = context.read<PosSelectionCubit>().state;
              // Create a repository based on the selected POS.
              final repository = createDatabaseForPos(pos);
              final bloc = StockManagementBloc(repository);
              bloc.add(LoadStockEvent());
              return bloc;
            },
          ),
          // Provide additional POS-dependent blocs as needed:
          BlocProvider<FileStockBloc>(
            create: (context) {
              final repository = createDatabaseForPos(
                context.read<PosSelectionCubit>().state,
              );
              return FileStockBloc(
                  repository, context.read<StockManagementBloc>());
            },
          ),
          BlocProvider<StockSyncBloc>(
            create: (context) {
              final repository = createDatabaseForPos(
                context.read<PosSelectionCubit>().state,
              );
              return StockSyncBloc(
                  repository, context.read<StockManagementBloc>());
            },
          ),
          BlocProvider<RefillHistoryBloc>(
            create: (context) {
              final repository = createDatabaseForPos(
                context.read<PosSelectionCubit>().state,
              );
              return RefillHistoryBloc(
                  repository, context.read<StockManagementBloc>());
            },
          ),
          // These blocs may or may not be POS-dependent:
          BlocProvider<RecipeParserBloc>(
            create: (context) => RecipeParserBloc(cocktailRecipeRepository),
          ),
          BlocProvider<SalesParserBloc>(
            create: (context) => SalesParserBloc(),
          ),
        ],
        child: HomePage(
          stockRepository: createDatabaseForPos(
            // Pass the initial POS; later when the user changes it,
            // you would need to reinitialize these blocs.
            context.read<PosSelectionCubit>().state,
          ),
        ),
      ),
    );
  }*/
}
