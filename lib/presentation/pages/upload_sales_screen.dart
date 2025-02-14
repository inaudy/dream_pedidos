import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:dream_pedidos/presentation/blocs/sales_parser_bloc/sales_parser_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_sync_bloc/stock_sync_bloc.dart';
import 'package:dream_pedidos/presentation/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UploadSalesPage extends StatelessWidget {
  const UploadSalesPage({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildButtonSection(context),
          const SizedBox(height: 20),
          _buildSalesSyncListener(),
          _buildSalesDataSection(),
        ],
      ),
    );
  }

  /// 🔹 Builds button section for importing sales & syncing stock
  Widget _buildButtonSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CommonButton(
            icon: Icons.upload_file,
            label: 'Importar Ventas',
            onPressed: () => context
                .read<SalesParserBloc>()
                .add(SalesParserPickFileEvent())),
        CommonButton(
            icon: Icons.sync,
            label: 'Actualizar Almacén',
            onPressed: () => _handleSyncStock(context)),
      ],
    );
  }

  /// 🔹 Handles syncing stock data based on parsed sales data
  void _handleSyncStock(BuildContext context) {
    final salesState = context.read<SalesParserBloc>().state;
    final stockSyncState = context.read<StockSyncBloc>().state;

    if (stockSyncState is StockSyncLoading) {
      _showSnackBar(context, 'Sincronización en progreso...');
      return;
    }

    if (salesState is SalesParserSuccess && salesState.salesData.isNotEmpty) {
      context.read<StockSyncBloc>().add(SyncStockEvent(salesState.salesData));
    } else {
      _showSnackBar(context, 'Error, datos no válidos.');
    }
  }

  /// 🔹 Listens for stock sync success/error messages
  Widget _buildSalesSyncListener() {
    return BlocListener<StockSyncBloc, StockSyncState>(
      listener: (context, state) {
        if (state is StockSyncError) {
          _showSnackBar(context, state.message);
        } else if (state is StockSyncSuccess) {
          _showSnackBar(context, 'Almacén actualizado correctamente!');
        }
      },
      child: const SizedBox.shrink(), // No UI needed for listener
    );
  }

  /// 🔹 Displays sales data with error handling
  Widget _buildSalesDataSection() {
    return Expanded(
      child: BlocConsumer<SalesParserBloc, SalesParserState>(
        listener: (context, state) {
          if (state is SalesParserFailure) {
            _showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is SalesParserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesParserSuccess) {
            return _buildSalesList(state.salesData);
          } else if (state is SalesParserFailure) {
            return const Center(
                child: Text('Carga fallida, revisa tu archivo.'));
          }
          return const Center(child: Text('Sin datos.'));
        },
      ),
    );
  }

  /// 🔹 Displays the imported sales data
  Widget _buildSalesList(List<SalesData> salesData) {
    return ListView.builder(
      itemCount: salesData.length,
      itemBuilder: (context, index) {
        final data = salesData[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.trending_down, color: Colors.redAccent),
            title: Text(
              data.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'Ventas: ${data.salesVolume.toInt()}\nFecha: ${DateFormat('dd/MM/yyyy').format(data.date)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
