/*import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:dream_pedidos/presentation/pages/stock_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/stock_bloc/stock_bloc.dart';
import '/blocs/stock_bloc/stock_state.dart';

class StockListPage extends StatelessWidget {
  const StockListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.read<StockBloc>().state is StockInitial) {
      context.read<StockBloc>().add(LoadStockEvent());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Stock List')),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockLoaded) {
            final stockItems = state.stockItems;
            return ListView.builder(
              itemCount: stockItems.length,
              itemBuilder: (context, index) {
                final item = stockItems[index];
                return ListTile(
                  title: Text(item.itemName),
                  subtitle: Text(
                      'Cant: ${item.actualStock} (Min: ${item.minimumLevel}, Max: ${item.maximumLevel})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StockEditPage(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is StockError) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return const Center(child: Text('No data available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StockEditPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/