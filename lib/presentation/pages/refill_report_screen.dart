import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/item_selection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RefillReportPage extends StatelessWidget {
  final StockRepository stockRepository;

  const RefillReportPage({super.key, required this.stockRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StockManagementBloc, StockManagementState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockError) {
            return _buildErrorMessage(state.message);
          } else if (state is StockLoaded) {
            // 🔹 **Filter out only items that need refilling**
            final filteredStockItems = state.stockItems
                .where((item) =>
                        item.actualStock <=
                            item
                                .minimumLevel && // 🔹 If stock is at or below min, order
                        !(item.actualStock == item.minimumLevel &&
                            item.minimumLevel ==
                                item.maximumLevel) // 🔹 EXCLUDE cases where min == max == actual
                    )
                .toList();

            if (filteredStockItems.isEmpty) {
              return const Center(
                child: Text(
                  'No hay productos para reponer',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return _buildStockList(context, filteredStockItems);
          }
          return const Center(child: Text('Sin datos disponibles.'));
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 🔹 Show error messages
  Widget _buildErrorMessage(String? message) {
    return Center(
      child: Text(
        'Error: ${message ?? "Error desconocido"}',
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 🔹 Build stock list with filtered items
  Widget _buildStockList(BuildContext context, List<StockItem> stockItems) {
    final categorizedData = _categorizeStockItems(stockItems);

    return ListView(
      children: categorizedData.keys.map((category) {
        final items = categorizedData[category]!;
        return _buildCategorySection(context, category, items);
      }).toList(),
    );
  }

  /// 🔹 Build categories
  Widget _buildCategorySection(
      BuildContext context, String category, List<StockItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFBA0C2F).withOpacity(0.8),
          ),
          child: Row(
            children: [
              Text(
                category.isEmpty ? 'Sin Categoría' : category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildStockItem(context, item)),
      ],
    );
  }

  /// 🔹 Build each stock item with text input and selection
  Widget _buildStockItem(BuildContext context, StockItem item) {
    final String itemKey = item.itemName;
    final refillQuantity = item.maximumLevel - item.actualStock;
    final TextEditingController controller = TextEditingController(
      text: NumberFormat('#.#').format(refillQuantity).toString(),
    );

    return BlocBuilder<ItemSelectionCubit, ItemSelectionState>(
      builder: (context, state) {
        final isSelected = state.selectedItems.contains(item);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: SizedBox(
              width: 50, height: 40, // Fixed width for the refill quantity
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 2),
                ),
                onChanged: (value) {
                  context.read<ItemSelectionCubit>().updateItemQuantity(
                        itemKey,
                        double.tryParse(value) ?? 0,
                      );
                },
              ),
            ),
            title: Text(
              item.itemName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Actual:${NumberFormat('#.#').format(item.actualStock)} | Min: ${NumberFormat('#.#').format(item.minimumLevel)} | Max: ${NumberFormat('#.#').format(item.maximumLevel)}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (selected) {
                if (selected == true) {
                  context.read<ItemSelectionCubit>().selectItem(item);
                } else {
                  context.read<ItemSelectionCubit>().deselectItem(item);
                }
              },
            ),
          ),
        );
      },
    );
  }

  /// 🔹 Bottom bar to submit selected items
  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Enviar Selección'),
              onPressed: () => _bulkUpdateStock(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Update stock for selected items
  Future<void> _bulkUpdateStock(BuildContext context) async {
    final itemSelectionCubit = context.read<ItemSelectionCubit>();
    final stockBloc = context.read<StockManagementBloc>();
    final selectedItems = itemSelectionCubit.state.selectedItems;

    if (selectedItems.isEmpty) {
      _showSnackBar(context, 'No hay items seleccionados');
      return;
    }

    List<StockItem> updatedItems = [];

    for (final item in selectedItems) {
      final newQuantity = itemSelectionCubit.state.quantities[item.itemName] ??
          (item.maximumLevel - item.actualStock);

      final updatedStock = item.actualStock + newQuantity;

      if (updatedStock < item.maximumLevel) {
        updatedItems.add(item.copyWith(actualStock: updatedStock));
      }
    }

    for (final updatedItem in updatedItems) {
      await stockRepository.updateStockItem(updatedItem);
    }

    itemSelectionCubit.clearSelection();
    stockBloc.add(LoadStockEvent()); // 🔹 Reload stock to reflect changes

    if (context.mounted) {
      _showSnackBar(context, 'Stock actualizado para los items seleccionados');
    }
  }

  /// 🔹 Show Snackbar messages
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 🔹 Categorize stock items
  Map<String, List<StockItem>> _categorizeStockItems(
      List<StockItem> stockItems) {
    final categorized = <String, List<StockItem>>{};

    for (var item in stockItems) {
      final category = item.category.isEmpty ? 'Sin Categoría' : item.category;
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(item);
    }

    return categorized;
  }
}
