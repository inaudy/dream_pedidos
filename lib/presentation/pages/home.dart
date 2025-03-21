import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/pos_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/stock_search_cubit.dart';
import 'package:dream_pedidos/presentation/pages/ean13_scanner_page.dart';
import 'package:dream_pedidos/presentation/pages/pdf_service.dart';
import 'package:dream_pedidos/presentation/pages/pos_selection_page.dart';
import 'package:dream_pedidos/presentation/pages/refill_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_pedidos/presentation/widgets/refill_edit_dialog.dart';
import 'package:dream_pedidos/presentation/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/presentation/pages/config.dart';
import 'package:dream_pedidos/presentation/pages/refill_report_screen.dart';
import 'package:dream_pedidos/presentation/pages/stock_screen.dart';
import 'package:dream_pedidos/presentation/pages/upload_sales_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dream_pedidos/data/repositories/excel_service.dart';

class HomePage extends StatelessWidget {
  final StockRepository stockRepository;

  const HomePage({super.key, required this.stockRepository});

  List<Widget> get _pages => [
        const UploadSalesPage(),
        const StockManagePage(),
        const RefillReportPage(),
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
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        context.read<StockSearchCubit>().toggleSearch();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.scanBarcode,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final scannedCode = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EAN13ScannerPage(),
                          ),
                        );

                        if (scannedCode != null && scannedCode is String) {
                          if (!context.mounted)
                            return; // Prevent calling setState on unmounted widget.
                          final stockState =
                              context.read<StockManagementBloc>().state;
                          if (stockState is StockLoaded) {
                            final matchingItem =
                                stockState.stockItems.firstWhere(
                              (item) =>
                                  item.eanCode?.trim() == scannedCode.trim(),
                              orElse: () => StockItem(
                                itemName: '',
                                actualStock: 0,
                                minimumLevel: 0,
                                maximumLevel: 0,
                                category: '',
                                traspaso: '',
                                eanCode: '',
                                errorPercentage: 0,
                              ),
                            );

                            if (matchingItem.itemName.isNotEmpty) {
                              // Open a dialog to update actual stock.
                              EditValueDialog.show(
                                context,
                                title: matchingItem.itemName,
                                labelText: 'Stock Actual',
                                initialValue: matchingItem.actualStock,
                                onSave: (newActualStock) {
                                  final updatedItem = matchingItem.copyWith(
                                    actualStock: newActualStock,
                                  );
                                  // Dispatch an event to update the actual stock.
                                  context.read<StockManagementBloc>().add(
                                        UpdateStockItemEvent(updatedItem, 0),
                                      );
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'No se encontró ningún producto con ese código.'),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.email, color: Colors.white),
                      tooltip: "Enviar Excel",
                      onPressed: () async {
                        final stockState =
                            context.read<StockManagementBloc>().state;
                        final posState =
                            context.read<PosSelectionCubit>().state;
                        final posName = posState.name;

                        if (stockState is StockLoaded) {
                          // Apply the same filter as before to get only items that need refilling.
                          final filteredStockItems =
                              stockState.stockItems.where((item) {
                            return item.actualStock <= item.minimumLevel &&
                                !(item.actualStock == item.minimumLevel &&
                                    item.minimumLevel == item.maximumLevel);
                          }).toList();

                          if (filteredStockItems.isEmpty) {
                            _showSnackBar(context,
                                '⚠️ No hay productos para generar el Excel');
                            return;
                          }

                          _showSnackBar(
                              context, '📤 Enviando Excel por correo...');

                          try {
                            await ExcelService.sendEmailWithExcelFromDB(
                                stockRepository, posName);
                            if (!context.mounted) return;
                            _showSnackBar(
                                context, '✅ Correo enviado con éxito.');
                          } catch (e) {
                            _showSnackBar(
                                context, '❌ Error al enviar el correo: $e');
                          }
                        }
                      },
                    ),
                  ],
                );
              } else if (navState == 2) {
                return IconButton(
                  icon: const Icon(Icons.email, color: Colors.white),
                  onPressed: () async {
                    final stockState =
                        context.read<StockManagementBloc>().state;
                    final posState = context.read<PosSelectionCubit>().state;
                    final posName = posState.name;

                    if (stockState is StockLoaded) {
                      final filteredStockItems =
                          stockState.stockItems.where((item) {
                        return item.actualStock <= item.minimumLevel &&
                            !(item.actualStock == item.minimumLevel &&
                                item.minimumLevel == item.maximumLevel);
                      }).toList();

                      if (filteredStockItems.isEmpty) {
                        _showSnackBar(
                            context, '⚠️ No hay productos para generar el PDF');
                        return;
                      }

                      _showSnackBar(context, '📤 Enviando PDF por correo...');

                      try {
                        await PdfService.sendEmailWithPdf(
                            filteredStockItems, posName);
                        if (!context.mounted)
                          return; // Prevent calling setState on unmounted widget.
                        _showSnackBar(context, '✅ Correo enviado con éxito.');
                      } catch (e) {
                        _showSnackBar(
                            context, '❌ Error al enviar el correo: $e');
                      }
                    }
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 16),
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.blue),
                  title: const Text(
                    'Cambiar Almacen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PosSelectionPage()));
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
                  title: 'Almacén',
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
                  icon: Icons.history,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 60,
          ),
          const SizedBox(height: 8),
          BlocBuilder<PosSelectionCubit, PosType>(
            builder: (context, pos) {
              return Text(
                pos.name,
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
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () {
        if (title == "Cambiar Almacen") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const PosSelectionPage()));
        } else {
          _navigateToPage(context, pageIndex);
        }
      },
      horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      dense: true,
    );
  }

  void _navigateToPage(BuildContext context, int pageIndex) {
    context.read<BottomNavcubit>().updateIndex(pageIndex);
    Navigator.of(context).pop();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
