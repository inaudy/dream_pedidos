import 'package:dream_pedidos/blocs/cubit/bottom_nav_cubit.dart';
import 'package:dream_pedidos/blocs/file_bloc/file_escandallos_bloc.dart';
import 'package:dream_pedidos/blocs/file_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:dream_pedidos/presentation/pages/refill_report_screen.dart';
import 'package:dream_pedidos/presentation/pages/stock_upload_screen.dart';
import 'package:dream_pedidos/presentation/pages/upload_sales_screen.dart';
import 'package:file_picker/file_picker.dart';
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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Opens the drawer from the top
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuration',
            onPressed: () {
              _showConfigurationDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(),
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

  void _showConfigurationDialog(BuildContext outerContext) {
    final fileStockBloc = outerContext.read<FileStockBloc>();
    final fileEscandallosBloc = outerContext.read<FileEscandallosBloc>();
    final stockBloc = outerContext.read<StockBloc>();
    final messenger = ScaffoldMessenger.of(outerContext);

    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Configuracion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reset Stock Button
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _resetStock(stockBloc,
                          messenger); // Pass the required dependencies
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset Stock'),
                    style: ElevatedButton.styleFrom(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Upload XML Button
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _uploadFile(fileStockBloc,
                          messenger); // Pass messenger instead of context
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Stocks'),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _uploadEscandallos(fileEscandallosBloc,
                          messenger); // Pass messenger instead of context
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Escandallos'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    dialogContext); // Use dialogContext for dialog operations
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Simulates XML Upload Logic
  Future<void> _uploadFile(
      FileStockBloc fileStockBloc, ScaffoldMessengerState messenger) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'], // Limit to specific file types
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      fileStockBloc.add(FileStockUploadEvent(filePath));
    } else {
      // If user cancels or no file is selected
      messenger.showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  Future<void> _uploadEscandallos(FileEscandallosBloc fileEscandallosBloc,
      ScaffoldMessengerState messenger) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'], // Limit to specific file types
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      fileEscandallosBloc.add(FileEscandallosUploadEvent(filePath));
    } else {
      // If user cancels or no file is selected
      messenger.showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  /// Simulates Stock Reset Logic

  void _resetStock(StockBloc stockBloc, ScaffoldMessengerState messenger) {
    // Dispatch events to reset stock
    stockBloc.add(DeleteAllStockEvent());
    stockBloc.add(LoadStockEvent());

    // Show success message
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Todos los stocks han sido eliminados.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
