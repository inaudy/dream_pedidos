import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:dream_pedidos/presentation/blocs/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_event.dart';
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
<<<<<<< HEAD:lib/presentation/pages/upload_sales_screen.dart
                onPressed: () => context
                    .read<SalesParserBloc>()
                    .add(SalesParserPickFileEvent()),
=======
                onPressed: () => fileBloc.add(SalesParserPickFileEvent()),
>>>>>>> 0a869fd99f174b0a4d4d93d51db1695a8098767f:lib/core/features/stock_managment/presentation/pages/upload_sales_screen.dart
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
<<<<<<< HEAD:lib/presentation/pages/upload_sales_screen.dart
                  final salesState = context.read<SalesParserBloc>().state;
                  if (salesState is SalesParserSuccess &&
                      salesState.salesData.isNotEmpty) {
                    context
                        .read<StockBloc>()
                        .add(SyncStockEvent(salesState.salesData));
=======
                  final salesState = fileBloc.state;
                  if (salesState is SalesParserSuccess && salesState.salesData.isNotEmpty) {
                    stockBloc.add(SyncStockEvent(salesState.salesData));
>>>>>>> 0a869fd99f174b0a4d4d93d51db1695a8098767f:lib/core/features/stock_managment/presentation/pages/upload_sales_screen.dart
                    _showSnackBar(context, 'Stock synced successfully!');
                  } else {
                    _showSnackBar(context, 'Sync failed: no valid data.');
                  }
                },
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
