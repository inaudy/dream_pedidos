import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/pages/config.dart';
import 'package:dream_pedidos/presentation/pages/refill_report_screen.dart';
import 'package:dream_pedidos/presentation/pages/stock_screen.dart';
import 'package:dream_pedidos/presentation/pages/upload_sales_screen.dart';

class HomePage extends StatelessWidget {
  final List<Widget> _pages = [
    const UploadSalesPage(),
    const StockManagePage(),
    RefillReportPage(),
    const ConfigPage(),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: BlocBuilder<BottomNavcubit, int>(
          builder: (context, state) {
            final List<String> appBarsTitle = [
              'ACTUALIZAR VENTAS',
              'STOCK ARECA',
              'LISTA PEDIDOS',
              'CONFIGURACION',
            ];
            return Text(
              appBarsTitle[state],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFBA0C2F),
        elevation: 2.0,
        actions: [
          BlocBuilder<BottomNavcubit, int>(
            builder: (context, state) {
              if (state == 1) {
                // Show search icon only on StockManagePage
                return IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    context.read<StockBloc>().add(ToggleSearchEvent());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: BlocBuilder<BottomNavcubit, int>(
        builder: (context, currentIndex) {
          return _pages[currentIndex];
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.upload_file,
                  title: 'Actualizar Ventas Ayer',
                  pageIndex: 0,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.list,
                  title: 'Stock Areca',
                  pageIndex: 1,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.report,
                  title: 'Pedidos Areca',
                  pageIndex: 2,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configuración',
                  pageIndex: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Color(0xFFBA0C2F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 40,
              color: Color(0xFFBA0C2F),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'MENU PRINCIPAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required int pageIndex}) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFBA0C2F),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        _navigateToPage(context, pageIndex);
      },
      horizontalTitleGap: 0.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
    );
  }

  void _navigateToPage(BuildContext context, int pageIndex) {
    context.read<BottomNavcubit>().updateIndex(pageIndex);
    Navigator.of(context).pop(); // Close the drawer
  }
}
