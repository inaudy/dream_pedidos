import 'package:dream_pedidos/presentation/blocs/recipe_parser_bloc/recipe_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_parser_bloc/file_stock_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fileStockBloc = context.read<FileStockBloc>();
    final fileEscandallosBloc = context.read<RecipeParserBloc>();
    final stockBloc = context.read<StockManagementBloc>();
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildConfigButton(
              icon: Icons.restart_alt,
              label: 'Reset Stock',
              //color: Colors.red,
              onPressed: () => _resetStock(stockBloc, messenger),
            ),
            const SizedBox(height: 16),
            _buildConfigButton(
              icon: Icons.upload_file,
              label: 'Cargar Stocks',
              //color: Colors.blue,
              onPressed: () => _uploadFile(fileStockBloc, messenger),
            ),
            const SizedBox(height: 16),
            _buildConfigButton(
              icon: Icons.upload_file,
              label: 'Cargar Escandallos',
              //color: Colors.blue,
              onPressed: () =>
                  _uploadEscandallos(fileEscandallosBloc, messenger),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        //foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

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

  Future<void> _uploadEscandallos(RecipeParserBloc fileEscandallosBloc,
      ScaffoldMessengerState messenger) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      fileEscandallosBloc.add(RecipeParserUploadEvent(filePath));
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  void _resetStock(
      StockManagementBloc stockBloc, ScaffoldMessengerState messenger) {
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
