import 'package:dream_pedidos/blocs/cubit/bottom_Nav_Cubit.dart';
import 'package:dream_pedidos/blocs/file_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/blocs/sales_data_bloc/sales_data_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/presentation/pages/home.dart';
import 'package:dream_pedidos/services/repositories/sales_repository.dart';
import 'package:dream_pedidos/services/repositories/stock_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            create: (context) => SalesDataBloc(SalesRepository()),
          ),
          BlocProvider(
            create: (context) => StockBloc(StockRepository()),
          ),
          BlocProvider(create: (context) => BottomNavcubit())
        ],
        child: HomePage(),
      ),
    );
  }
}
