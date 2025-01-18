import 'package:dream_pedidos/blocs/file_bloc/file_stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_state.dart';
import 'package:dream_pedidos/models/stock_item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StockManagePage extends StatelessWidget {
  const StockManagePage({super.key});

  /// Method to delete all stock data
  void _deleteAllData(StockBloc stockBloc) {
    stockBloc.add(DeleteAllStockEvent());
    stockBloc.add(LoadStockEvent());
  }

  /// Method to upload data from a file
  Future<void> _uploadFile(FileStockBloc fileStockBloc, StockBloc stockBloc,
      ScaffoldMessengerState messenger) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'], // Limit to specific file types
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      fileStockBloc.add(FileStockUploadEvent(filePath));
      stockBloc.add(LoadStockEvent());
    } else {
      // If user cancels or no file is selected
      messenger.showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockBloc = context.read<StockBloc>();
    final fileStockBloc = context.read<FileStockBloc>();
    final messenger = ScaffoldMessenger.of(context);

    stockBloc.add(LoadStockEvent());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _uploadFile(fileStockBloc, stockBloc, messenger),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Nuevos stocks'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    _deleteAllData(stockBloc);
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Todos los datos de stock borrados')),
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Todos datos'),
                ),
              ],
            ),*/
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<StockBloc, StockState>(
                builder: (context, state) {
                  if (state is StockLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StockLoaded) {
                    // Display the actual stored data
                    return _buildStoredDataList(state.stockItems);
                  } else if (state is StockError) {
                    return Center(
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(child: Text('No data available.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget to display the list of stored stock data
  Widget _buildStoredDataList(List<StockItem> stockData) {
    return ListView.builder(
      itemCount: stockData.length,
      itemBuilder: (context, index) {
        final data = stockData[index];
        return ListTile(
          //leading: const Icon(Icons.inventory),
          title: Text(
            data.itemName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Actual Stock: ${data.actualStock}\nMin: ${data.minimumLevel}\nMax: ${data.maximumLevel}',
          ),
        );
      },
    );
  }
}
