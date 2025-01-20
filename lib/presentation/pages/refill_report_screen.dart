import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '/models/stock_item.dart';
import '/services/repositories/stock_repository.dart';
import '/blocs/cubit/item_selection_cubit.dart';

class RefillReportPage extends StatelessWidget {
  final StockRepository stockRepository = StockRepository();

  RefillReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dispatch LoadStockEvent to ensure stock data is loaded
    context.read<StockBloc>().add(LoadStockEvent());

    return Scaffold(
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is StockLoaded && state.stockItems.isEmpty) {
            return const Center(
              child: Text('No hay nada para reponer'),
            );
          } else if (state is StockLoaded) {
            final categorizedData = _categorizeStockItems(state.stockItems);

            return ListView(
              children: categorizedData.keys.map((category) {
                final items = categorizedData[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        category.isEmpty ? 'Uncategorized' : category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...items.map((item) {
                      final refillQuantity =
                          item.maximumLevel - item.actualStock;
                      return BlocBuilder<ItemSelectionCubit,
                          ItemSelectionState>(
                        builder: (context, state) {
                          final isSelected = state.selectedItems.contains(item);
                          return GestureDetector(
                            child: ListTile(
                              tileColor: isSelected
                                  ? Colors.green.withOpacity(0.2)
                                  : null,
                              title: Text(
                                item.itemName,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  'Actual: ${item.actualStock}\nMin: ${item.minimumLevel}\nMax: ${item.maximumLevel}'),
                              trailing: Text(
                                'Cant: ${NumberFormat('#.#').format(refillQuantity)}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () => context
                                .read<ItemSelectionCubit>()
                                .toggleItemSelection(item),
                          );
                        },
                      );
                    }),
                    const Divider(
                      color: Colors.black45,
                      thickness: 1,
                    ),
                  ],
                );
              }).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Enviar'),
              onPressed: () => _bulkUpdateStock(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Map<String, List<StockItem>> _categorizeStockItems(
      List<StockItem> stockItems) {
    final refillItems = stockItems.where((item) {
      return item.actualStock < item.minimumLevel;
    });

    final Map<String, List<StockItem>> categorized = {};
    for (var item in refillItems) {
      final category = item.category;
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(item);
    }
    return categorized;
  }

  Future<void> _bulkUpdateStock(BuildContext context) async {
    final itemSelectionCubit = context.read<ItemSelectionCubit>();
    final stockBloc = context.read<StockBloc>();
    final selectedItems = itemSelectionCubit.state.selectedItems;

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay items seleccionados')),
      );
      return;
    }

    for (final item in selectedItems) {
      final updatedItem = item.copyWith(actualStock: item.maximumLevel);
      await stockRepository.updateStockItem(updatedItem);
    }

    // Clear selection
    itemSelectionCubit.clearSelection();

    // Reload stock data
    stockBloc.add(LoadStockEvent());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Stock actualizado para los items seleccionados')),
    );
  }
}
