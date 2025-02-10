import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/stock_search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class StockManagePage extends StatelessWidget {
  const StockManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StockManagementBloc, StockManagementState>(
      listener: (context, state) {
        if (state is StockLoaded &&
            state.message == 'Stock updated successfully.') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Stock actualizado correctamente")),
          );
        }
      },
      builder: (context, state) {
        final searchState = context.watch<StockSearchCubit>().state;
        if (state is StockLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StockLoaded) {
          final filteredStock =
              _applySearchFilter(state.stockItems, searchState.query);
          return Scaffold(
            appBar: AppBar(
              title: const Text("Stock Management"),
              actions: [
                IconButton(
                  icon:
                      Icon(searchState.isVisible ? Icons.close : Icons.search),
                  onPressed: () =>
                      context.read<StockSearchCubit>().toggleSearch(),
                ),
              ],
            ),
            body: Column(
              children: [
                if (searchState.isVisible)
                  _buildSearchBar(context), // ✅ Conditionally render search bar
                Expanded(child: _buildCategorizedList(context, filteredStock)),
              ],
            ),
          );
        }
        return const Center(child: Text('No hay datos disponibles.'));
      },
    );
  }

  void _showStockEditDialog(BuildContext context, StockItem item) {
    if (item.itemName.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        TextEditingController stockController = TextEditingController(
          text: item.actualStock.toString(),
        );

        return AlertDialog(
          title: Text(item.itemName),
          content: TextFormField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Stock Actual'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedStock = double.tryParse(stockController.text);
                if (updatedStock != null) {
                  context.read<StockManagementBloc>().add(
                        UpdateStockItemEvent(
                          item.copyWith(actualStock: updatedStock),
                        ),
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (query) =>
            context.read<StockSearchCubit>().updateSearchQuery(query),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => context.read<StockSearchCubit>().clearSearch(),
          ),
          hintText: 'Buscar...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  List<StockItem> _applySearchFilter(List<StockItem> stockItems, String query) {
    if (query.isEmpty) return stockItems;
    return stockItems
        .where(
            (item) => item.itemName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _buildCategorizedList(
      BuildContext context, List<StockItem> stockItems) {
    final categories = _categorizeStockItems(stockItems);
    return ListView(
      children: categories.entries.map((entry) {
        return _buildCategorySection(context, entry.key, entry.value);
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
    return Slidable(
      key: ValueKey(item.itemName),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _showStockEditDialog(context, item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2.0,
        child: ListTile(
          title: Text(
            item.itemName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              'Mín: ${NumberFormat('#.#').format(item.minimumLevel)} | Máx: ${NumberFormat('#.#').format(item.maximumLevel)} | Traspaso: ${item.traspaso}'),
          leading: Text(
            NumberFormat('#.#').format(item.actualStock),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Map<String, List<StockItem>> _categorizeStockItems(
      List<StockItem> stockItems) {
    final Map<String, List<StockItem>> categories = {};
    for (var item in stockItems) {
      final category = item.category.isEmpty ? 'Sin Categoría' : item.category;
      categories.putIfAbsent(category, () => []).add(item);
    }
    return categories;
  }
}
