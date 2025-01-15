import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '/blocs/file_bloc/file_bloc.dart';
import '/models/sales_data.dart';

class UploadSalesPage extends StatelessWidget {
  const UploadSalesPage({super.key});

  Future<void> _pickFile(BuildContext context, FileBloc fileBloc) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      fileBloc.add(FileUploadEvent(filePath));
    } else {
      // Show a SnackBar if no file is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  void _syncStock(
      BuildContext context, FileBloc fileBloc, StockBloc stockBloc) {
    final salesState = fileBloc.state;

    if (salesState is FileUploadSuccess && salesState.salesData.isNotEmpty) {
      stockBloc.add(SyncStockEvent(salesState.salesData));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock synced successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync failed: no valid data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileBloc = context.read<FileBloc>();
    final stockBloc = context.read<StockBloc>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickFile(context, fileBloc),
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => _syncStock(context, fileBloc, stockBloc),
                icon: const Icon(Icons.sync),
                label: const Text('Sinc Inv'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocListener<FileBloc, FileState>(
              listener: (context, state) {
                if (state is FileUploadFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
                }
              },
              child: BlocBuilder<FileBloc, FileState>(
                builder: (context, state) {
                  if (state is FileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FileUploadSuccess) {
                    return _buildSuccessList(state.salesData);
                  } else if (state is FileUploadFailure) {
                    return const Center(
                      child: Text('Upload failed, check your file.'),
                    );
                  }
                  return const Center(child: Text('Sin datos.'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessList(List<SalesData> salesData) {
    return ListView.builder(
      itemCount: salesData.length,
      itemBuilder: (context, index) {
        final data = salesData[index];
        return ListTile(
          leading: const Icon(Icons.trending_down),
          title: Text(data.itemName),
          subtitle: Text(
            'Ventas: ${data.salesVolume.toInt()}\nFecha: ${DateFormat('dd/MM/yyyy').format(data.date)}',
          ),
        );
      },
    );
  }
}
