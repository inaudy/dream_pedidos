import 'package:dream_pedidos/blocs/sales_data_bloc/sales_data_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '/blocs/file_bloc/file_bloc.dart';
import '/models/sales_data.dart';

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Ayer'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => FileBloc(),
        child: UploadBody(),
      ),
    );
  }
}

class UploadBody extends StatefulWidget {
  @override
  _UploadBodyState createState() => _UploadBodyState();
}

class _UploadBodyState extends State<UploadBody> {
  /// Method to pick a file and send the event to the bloc
  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'], // Limit to specific file types
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      context.read<FileBloc>().add(FileUploadEvent(filePath));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  void _syncStock(BuildContext context) {
    final salesState = context.read<FileBloc>().state;

    if (salesState is FileUploadSuccess && salesState.salesData.isNotEmpty) {
      context.read<StockBloc>().add(SyncStockEvent(salesState.salesData));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stock sincronizado con las ventas de ayer')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sales data to synchronize')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickFile(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('desde XLSX'),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton.icon(
                onPressed: () => _syncStock(context),
                icon: const Icon(Icons.sync),
                label: const Text('Sinc con Inventario'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<FileBloc, FileState>(
              builder: (context, state) {
                if (state is FileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FileUploadSuccess) {
                  return _buildSuccessList(state.salesData);
                } else if (state is FileUploadFailure) {
                  return Center(
                    child: Text(
                      'Error: ${state.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const Center(child: Text('Sin datos.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget to display the list of uploaded sales data
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





/*import 'package:dream_pedidos/blocs/sales_data_bloc/sales_data_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '/blocs/file_bloc/file_bloc.dart';
import '/models/sales_data.dart';

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Ayer'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => FileBloc(),
        child: UploadBody(),
      ),
    );
  }
}

class UploadBody extends StatefulWidget {
  @override
  _UploadBodyState createState() => _UploadBodyState();
}

class _UploadBodyState extends State<UploadBody> {
  /// Method to pick a file and send the event to the bloc
  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'], // Limit to specific file types
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      context.read<FileBloc>().add(FileUploadEvent(filePath));
    } else {
      // If user cancels or no file is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickFile(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar desde XLSX'),
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton.icon(
                onPressed: () => _syncStock(context),
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar con Inventario'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<FileBloc, FileState>(
              builder: (context, state) {
                if (state is FileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FileUploadSuccess) {
                  return _buildSuccessList(state.salesData);
                } else if (state is FileUploadFailure) {
                  return Center(
                    child: Text(
                      'Error: ${state.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const Center(child: Text('Sin datos.'));
              },
            ),
          ),
        ],
      ),
    );
  }

void _syncStock(BuildContext context) {
  if (context.read()<SalesDataBloc>.isNotEmpty) {
    context.read<StockBloc>().add(SyncStockEvent(_salesData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock synchronized with sales data')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No sales data to synchronize')),
    );
  }
}

  /// Widget to display the list of uploaded sales data
  Widget _buildSuccessList(List<SalesData> salesData) {
    return ListView.builder(
      itemCount: salesData.length,
      itemBuilder: (context, index) {
        final data = salesData[index];
        return ListTile(
          leading: const Icon(Icons.trending_down),
          title: Text(data.itemName),
          subtitle: Text(
            'Ventas: ${data.salesVolume.toInt()}\nDate: ${DateFormat('dd/MM/yyyy').format(data.date)}',
          ),
        );
      },
    );
  }
}*/
