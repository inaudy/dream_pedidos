import 'package:dream_pedidos/blocs/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/pages/refill_report_screen.dart';
import 'package:dream_pedidos/presentation/pages/stock_upload_screen.dart';
import 'package:dream_pedidos/presentation/pages/upload_sales_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  final List<Widget> _pages = [
    const UploadSalesPage(),
    const StockManagePage(),
    RefillReportPage(),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
      ),
      body: BlocBuilder<BottomNavcubit, int>(
        builder: (context, currentIndex) {
          return _pages[currentIndex];
        },
      ),
      bottomNavigationBar: BlocBuilder<BottomNavcubit, int>(
        builder: (context, currentIndex) {
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              // Update the current index in the Cubit
              context.read<BottomNavcubit>().updateIndex(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.upload_file),
                label: 'Ventas Ayer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Stock',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.report),
                label: 'Pedidos',
              ),
            ],
          );
        },
      ),
    );
  }
}
