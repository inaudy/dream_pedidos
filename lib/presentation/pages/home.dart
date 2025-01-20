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
                // Open the drawer
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
        title: BlocBuilder<BottomNavcubit, int>(
          builder: (context, state) {
            final List<String> _appBarsTitle = [
              'Actualizar Ventas',
              'Stock Areca',
              'Lista Pedidos '
            ];
            return Text(_appBarsTitle[state]); // Dynamically set the title
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Acualizar Ventas Ayer'),
              onTap: () {
                _navigateToPage(context, 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Stock Areca'),
              onTap: () {
                _navigateToPage(context, 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Pedidos Areca'),
              onTap: () {
                _navigateToPage(context, 2);
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<BottomNavcubit, int>(
        builder: (context, currentIndex) {
          return _pages[currentIndex];
        },
      ),
    );
  }

  /// Show the configuration dialog
  void _showConfigurationDialog(BuildContext outerContext) {
    final fileStockBloc = outerContext.read<FileStockBloc>();
    final fileEscandallosBloc = outerContext.read<FileEscandallosBloc>();
    final stockBloc = outerContext.read<StockBloc>();
    final messenger = ScaffoldMessenger.of(outerContext);

    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Configuración'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reset Stock Button
              ElevatedButton.icon(
                onPressed: () {
                  _resetStock(stockBloc, messenger);
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset Stock'),
              ),
              const SizedBox(height: 16),
              // Upload XML Button
              ElevatedButton.icon(
                onPressed: () {
                  _uploadFile(fileStockBloc, messenger);
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Stocks'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _uploadEscandallos(fileEscandallosBloc, messenger);
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Escandallos'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Navigate to the selected page and close the drawer
  void _navigateToPage(BuildContext context, int pageIndex) {
    context.read<BottomNavcubit>().updateIndex(pageIndex);
    Navigator.of(context).pop(); // Close the drawer
  }

  /// Upload file logic
  Future<void> _uploadFile(
      FileStockBloc fileStockBloc, ScaffoldMessengerState messenger) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      fileStockBloc.add(FileStockUploadEvent(filePath));
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  /// Upload escandallos logic
  Future<void> _uploadEscandallos(FileEscandallosBloc fileEscandallosBloc,
      ScaffoldMessengerState messenger) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      fileEscandallosBloc.add(FileEscandallosUploadEvent(filePath));
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  /// Reset stock logic
  void _resetStock(StockBloc stockBloc, ScaffoldMessengerState messenger) {
    stockBloc.add(DeleteAllStockEvent());
    stockBloc.add(LoadStockEvent());

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Todos los stocks han sido eliminados.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
