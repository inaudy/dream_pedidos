import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/presentation/blocs/barcode_scanner_bloc/barcode_scanner_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/pages/ean13_scanner_page.dart';
import 'package:dream_pedidos/presentation/pages/refill_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/pages/config.dart';
import 'package:dream_pedidos/presentation/pages/refill_report_screen.dart';
import 'package:dream_pedidos/presentation/pages/stock_screen.dart';
import 'package:dream_pedidos/presentation/pages/upload_sales_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePage extends StatelessWidget {
  final StockRepository stockRepository;

  const HomePage({super.key, required this.stockRepository});

  List<Widget> get _pages => [
        const UploadSalesPage(),
        const StockManagePage(),
        RefillReportPage(stockRepository: stockRepository),
        const RefillHistoryPage(),
        const ConfigPage(),
      ];

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
              'VENTAS',
              'ALMACEN',
              'PEDIDO',
              'HISTORIAL DE REPOSICION',
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
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.white,
                      onPressed: () {
                        context
                            .read<StockManagementBloc>()
                            .add(ToggleSearchEvent());
                      },
                    ),
                    BlocListener<BarcodeScannerBloc, BarcodeScannerState>(
                      listener: (context, scannerState) {
                        if (scannerState is BarcodeScannedState) {
                          context
                              .read<StockManagementBloc>()
                              .add(SearchStockByEANEvent(scannerState.eanCode));
                        }
                      },
                      child: IconButton(
                        icon: const Icon(LucideIcons.scanBarcode,
                            color: Colors.white),
                        onPressed: () async {
                          final scannedCode = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EAN13ScannerPage()),
                          );

                          if (scannedCode != null && scannedCode is String) {
                            context
                                .read<BarcodeScannerBloc>()
                                .add(ScanBarcodeEvent(scannedCode));
                          }
                        },
                      ),
                    ),
                  ],
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
              padding: const EdgeInsets.only(left: 16),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.sync,
                  title: 'Ventas',
                  pageIndex: 0,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.store,
                  title: 'Almacen',
                  pageIndex: 1,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.list,
                  title: 'Pedido',
                  pageIndex: 2,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.list,
                  title: 'Historial de Reposición',
                  pageIndex: 3,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configuración',
                  pageIndex: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFFBA0C2F),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
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
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        _navigateToPage(context, pageIndex);
      },
      horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      dense: true,
    );
  }

  void _navigateToPage(BuildContext context, int pageIndex) {
    context.read<BottomNavcubit>().updateIndex(pageIndex);
    Navigator.of(context).pop(); // Close the drawer
  }
}
