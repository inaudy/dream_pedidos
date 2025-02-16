import 'package:dream_pedidos/presentation/blocs/recipe_parser_bloc/recipe_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_parser_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/presentation/widgets/common_button.dart';
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

    return BlocListener<FileStockBloc, FileStockState>(
      listener: (context, state) {
        if (state is FileStockUploadSuccess) {
          messenger.showSnackBar(
            const SnackBar(content: Text("✅ Stock cargado correctamente!")),
          );
        } else if (state is FileStockUploadFailure) {
          messenger.showSnackBar(
            SnackBar(content: Text("❌ Error: ${state.errorMessage}")),
          );
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonButton(
                icon: Icons.restart_alt,
                label: 'Reset Stock',
                onPressed: () => _resetStock(stockBloc, messenger),
              ),
              const SizedBox(height: 6),
              CommonButton(
                icon: Icons.upload_file,
                label: 'Cargar Stocks',
                onPressed: () =>
                    _uploadFile(stockBloc, fileStockBloc, messenger),
              ),
              const SizedBox(height: 6),
              CommonButton(
                icon: Icons.upload_file,
                label: 'Cargar Escandallos',
                onPressed: () =>
                    _uploadEscandallos(fileEscandallosBloc, messenger),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile(StockManagementBloc stockBloc,
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
