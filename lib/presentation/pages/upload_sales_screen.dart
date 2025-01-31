import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:dream_pedidos/presentation/blocs/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_sync_bloc/stock_sync_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UploadSalesPage extends StatelessWidget {
  const UploadSalesPage({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => context
                    .read<SalesParserBloc>()
                    .add(SalesParserPickFileEvent()),
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  final salesState = context.read<SalesParserBloc>().state;
                  final stockSyncState = context.read<StockSyncBloc>().state;

                  // Prevent duplicate sync if stock was already updated
                  if (stockSyncState is StockSyncLoading) {
                    _showSnackBar(context, 'Sincronización en progreso...');
                    return;
                  }

                  if (salesState is SalesParserSuccess &&
                      salesState.salesData.isNotEmpty) {
                    context
                        .read<StockSyncBloc>()
                        .add(SyncStockEvent(salesState.salesData));
                  } else {
                    _showSnackBar(context, 'Error, datos no válidos.');
                  }
                },
                icon: const Icon(Icons.sync),
                label: const Text('Actualizar Almacén'),
              ),

              SizedBox(height: 10), // Add some spacing
              BlocListener<StockSyncBloc, StockSyncState>(
                listener: (context, state) {
                  if (state is StockSyncError) {
                    _showSnackBar(context, state.message);
                  } else if (state is StockSyncSuccess) {
                    _showSnackBar(
                        context, 'Almacén actualizado correctamente!');
                  }
                },
                child:
                    Container(), // Dummy child as BlocListener does not render UI
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocListener<SalesParserBloc, SalesParserState>(
              listener: (context, state) {
                if (state is SalesParserFailure) {
                  _showSnackBar(context, state.error);
                }
              },
              child: BlocBuilder<SalesParserBloc, SalesParserState>(
                builder: (context, state) {
                  if (state is SalesParserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SalesParserSuccess) {
                    return _buildSuccessList(state.salesData);
                  } else if (state is SalesParserFailure) {
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
