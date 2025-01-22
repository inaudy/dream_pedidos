import 'package:dream_pedidos/core/features/stock_managment/data/models/sales_data.dart';
import 'package:dream_pedidos/core/features/stock_managment/presentation/bloc/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/core/features/stock_managment/presentation/bloc/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/core/features/stock_managment/presentation/bloc/stock_bloc/stock_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UploadSalesPage extends StatelessWidget {
  const UploadSalesPage({super.key});

  void _syncStock(
      BuildContext context, SalesParserBloc fileBloc, StockBloc stockBloc) {
    final salesState = fileBloc.state;

    if (salesState is SalesParserSuccess && salesState.salesData.isNotEmpty) {
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
    final fileBloc = context.read<SalesParserBloc>();
    final stockBloc = context.read<StockBloc>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<SalesParserBloc>()
                      .add(SalesParserPickFileEvent());
                },
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
            child: BlocListener<SalesParserBloc, SalesParserState>(
              listener: (context, state) {
                if (state is SalesParserFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
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
