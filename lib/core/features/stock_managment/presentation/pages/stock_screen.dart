import 'package:dream_pedidos/core/features/stock_managment/presentation/bloc/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/core/features/stock_managment/presentation/bloc/stock_bloc/stock_event.dart';
import 'package:dream_pedidos/core/features/stock_managment/presentation/bloc/stock_bloc/stock_state.dart';
import 'package:dream_pedidos/core/features/stock_managment/data/models/stock_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StockManagePage extends StatelessWidget {
  const StockManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stockBloc = context.read<StockBloc>();

    stockBloc.add(LoadStockEvent());
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        'Error: ${state.message}',
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
