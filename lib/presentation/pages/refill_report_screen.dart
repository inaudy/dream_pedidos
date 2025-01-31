import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/item_selection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RefillReportPage extends StatelessWidget {
  final StockRepository stockRepository;

  // Pass in the StockRepository as a dependency
  RefillReportPage({Key? key, required this.stockRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<StockManagementBloc>().add(LoadStockEvent());

    return Scaffold(
      body: BlocBuilder<StockManagementBloc, StockManagementState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockError) {
            return _buildErrorMessage(state.message);
          } else if (state is StockLoaded) {
            return _buildStockList(context, state.stockItems);
          }
          return const Center(child: Text('Sin datos disponibles.'));
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildErrorMessage(String? message) {
    return Center(
      child: Text(
        'Error: ${message ?? "Error desconocido"}',
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStockList(BuildContext context, List<StockItem> stockItems) {
    final categorizedData = _categorizeStockItems(stockItems);

    if (categorizedData.isEmpty) {
      return const Center(
        child: Text(
          'No hay nada para reponer',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView(
      children: categorizedData.keys.map((category) {
        final items = categorizedData[category]!;
        return _buildCategorySection(context, category, items);
      }).toList(),
    );
  }

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

  Widget _buildStockItem(BuildContext context, StockItem item) {
    final refillQuantity = item.maximumLevel - item.actualStock;

    return BlocBuilder<ItemSelectionCubit, ItemSelectionState>(
      builder: (context, state) {
        final isSelected = state.selectedItems.contains(item);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              if (selected == true) {
                context.read<ItemSelectionCubit>().selectItem(item);
              } else {
                context.read<ItemSelectionCubit>().deselectItem(item);
              }
            },
            title: Text(
              item.itemName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Actual: ${NumberFormat('#.#').format(item.actualStock)}\nMin: ${NumberFormat('#.#').format(item.minimumLevel)}\nMax: ${NumberFormat('#.#').format(item.maximumLevel)}',
            ),
            secondary: Text(
              NumberFormat('#.#').format(refillQuantity),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

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
              label: const Text('Enviar'),
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

  Map<String, List<StockItem>> _categorizeStockItems(
      List<StockItem> stockItems) {
    final refillItems = stockItems.where((item) {
      return item.actualStock < item.minimumLevel;
    });

    final Map<String, List<StockItem>> categorized = {};
    for (var item in refillItems) {
      final category = item.category;
      categorized.putIfAbsent(category, () => []).add(item);
    }
    return categorized;
  }

  Future<void> _bulkUpdateStock(BuildContext context) async {
    final itemSelectionCubit = context.read<ItemSelectionCubit>();
    final stockBloc = context.read<StockManagementBloc>();
    final selectedItems = itemSelectionCubit.state.selectedItems;

    if (selectedItems.isEmpty) {
      _showSnackBar(context, 'No hay items seleccionados');
      return;
    }

    for (final item in selectedItems) {
      final updatedItem = item.copyWith(actualStock: item.maximumLevel);
      await stockRepository.updateStockItem(updatedItem);
    }

    itemSelectionCubit.clearSelection();
    stockBloc.add(LoadStockEvent());
    if (context.mounted) {
      _showSnackBar(context, 'Stock actualizado para los items seleccionados');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
