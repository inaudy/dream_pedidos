import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/edit_stock_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/pos_cubit.dart';
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
        // Combine the page title and the selected POS in a Column.
        title: BlocBuilder<BottomNavcubit, int>(
          builder: (context, navState) {
            final List<String> appBarsTitle = [
              'VENTAS',
              'ALMACEN',
              'PEDIDO',
              'HISTORIAL DE REPOSICION',
              'CONFIGURACION',
            ];
            return BlocBuilder<PosSelectionCubit, PosType>(
              builder: (context, posState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appBarsTitle[navState],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "POS: ${posState.name}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFBA0C2F),
        elevation: 2.0,
        actions: [
          BlocBuilder<BottomNavcubit, int>(
            builder: (context, navState) {
              if (navState == 1) {
                // Show search and barcode icons only on StockManagePage
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
                    IconButton(
                      icon: const Icon(LucideIcons.scanBarcode,
                          color: Colors.white),
                      onPressed: () async {
                        // Launch the scanner page
                        final scannedCode = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EAN13ScannerPage(),
                          ),
                        );
                        if (scannedCode != null && scannedCode is String) {
                          // Access the current stock state (which remains unchanged)
                          final currentState =
                              context.read<StockManagementBloc>().state;
                          if (currentState is StockLoaded) {
                            final matchingItem =
                                currentState.stockItems.firstWhere(
                              (item) =>
                                  item.eanCode?.trim() == scannedCode.trim(),
                              orElse: () => StockItem(
                                itemName: '',
                                minimumLevel: 0,
                                maximumLevel: 0,
                                actualStock: 0,
                                category: '',
                                traspaso: '',
                                eanCode: '',
                                errorPercentage: 0,
                              ),
                            );
                            if (matchingItem.itemName.isNotEmpty) {
                              // Open the edit dialog for the matching item
                              _showStockEditDialog(context, matchingItem);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "No se encontró producto con ese código."),
                                ),
                              );
                            }
                          }
                        }
                      },
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDrawerHeader(),
          // Other drawer items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 16),
              children: [
                BlocBuilder<PosSelectionCubit, PosType>(
                  builder: (context, currentPos) {
                    return ExpansionTile(
                      title: const Text(
                        'Punto de Venta',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        currentPos.name,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      children: _buildPosList(context),
                    );
                  },
                ),
                const Divider(),
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

  /// Build the list of available POS options.
  List<Widget> _buildPosList(BuildContext context) {
    final posOptions = [
      {
        "title": "Restaurante",
        "pos": PosType.restaurant,
        "icon": Icons.restaurant,
      },
      {
        "title": "Beach Club",
        "pos": PosType.beachClub,
        "icon": Icons.beach_access,
      },
      {
        "title": "Bar Hall",
        "pos": PosType.bar,
        "icon": Icons.local_bar,
      },
    ];

    return posOptions.map((option) {
      return ListTile(
        leading: Icon(option["icon"] as IconData),
        title: Text(option["title"] as String),
        onTap: () {
          // Update the selected POS.
          context.read<PosSelectionCubit>().selectPos(option["pos"] as PosType);
          // Optionally, if you need to reinitialize POS-dependent blocs/repositories,
          // you can trigger a navigation pushReplacement here.
          Navigator.of(context).pop(); // Close the drawer.
        },
      );
    }).toList();
  }

  /// Drawer header (for example, including the logo)
  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFFBA0C2F),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 60,
          ),
          const SizedBox(height: 8),
          // Optionally, show the current POS here as well:
          BlocBuilder<PosSelectionCubit, PosType>(
            builder: (context, pos) {
              return Text(
                "POS: ${pos.name}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required int pageIndex}) {
    return ListTile(
      leading: Icon(icon),
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

  /// This dialog is used to edit a specific stock item.
  void _showStockEditDialog(BuildContext context, StockItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider(
          create: (_) => StockItemEditCubit(item),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: Text(item.itemName),
                content: BlocBuilder<StockItemEditCubit, StockItemEditState>(
                  builder: (context, state) {
                    return TextFormField(
                      initialValue: state.actualStock.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Stock Actual'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        context
                            .read<StockItemEditCubit>()
                            .actualStockChanged(value);
                      },
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final updatedItem = StockItem(
                        itemName: item.itemName,
                        minimumLevel: item.minimumLevel,
                        maximumLevel: item.maximumLevel,
                        actualStock: context
                            .read<StockItemEditCubit>()
                            .state
                            .actualStock,
                        category: item.category,
                        traspaso: item.traspaso,
                        eanCode: item.eanCode,
                        errorPercentage: item.errorPercentage,
                      );
                      // Dispatch the update event to StockManagementBloc.
                      context
                          .read<StockManagementBloc>()
                          .add(UpdateStockItemEvent(updatedItem));
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
