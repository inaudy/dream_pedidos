import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/stock_search_cubit.dart';
import 'package:dream_pedidos/presentation/widgets/stock_edit_dialog.dart';
import 'package:dream_pedidos/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StockManagePage extends StatefulWidget {
  const StockManagePage({super.key});

  @override
  State<StockManagePage> createState() => _StockManagePageState();
}

class _StockManagePageState extends State<StockManagePage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        List<StockItem> stockItems = [];
        if (state is StockLoaded) {
          stockItems = state.stockItems;
        } else if (state is StockUpdated) {
          stockItems = state.stockItems;
        }

        final filteredStock = _applySearchFilter(stockItems, searchState.query);
        return Column(
          children: [
            if (searchState.isVisible) _buildSearchBar(context),
            Expanded(child: _buildCategorizedList(context, filteredStock)),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) =>
            context.read<StockSearchCubit>().updateSearchQuery(query),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<StockSearchCubit>().clearSearch();
            },
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
          decoration:
              BoxDecoration(color: const Color(0xFFBA0C2F).withOpacity(0.8)),
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
    return BlocBuilder<StockManagementBloc, StockManagementState>(
      buildWhen: (previous, current) {
        if (current is StockUpdated) {
          // 🔹 Ensure rebuilding only for the updated item
          return current.updatedItem.itemName == item.itemName;
        }
        return false;
      },
      builder: (context, state) {
        final updatedItem = (state is StockUpdated &&
                state.updatedItem.itemName == item.itemName)
            ? state.updatedItem
            : item;
        return Slidable(
          key: ValueKey(item.itemName),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) {
                  // Use the generic dialog to update actual stock.
                  EditValueDialog.show(
                    context,
                    title: updatedItem.itemName,
                    labelText: 'Actual Stock',
                    initialValue: updatedItem.actualStock,
                    onSave: (newActualStock) {
                      // Create an updated item with the new stock.
                      final newItem =
                          updatedItem.copyWith(actualStock: newActualStock);
                      // Dispatch update event (refillQuantity is 0 in this case).
                      context
                          .read<StockManagementBloc>()
                          .add(UpdateStockItemEvent(newItem, 0));
                    },
                  );
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
              ),
            ],
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2.0,
            child: ListTile(
              title: Text(
                updatedItem.itemName, // ✅ Updates dynamically
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Mín: ${formatForDisplay(updatedItem.minimumLevel)} | Máx: ${formatForDisplay(updatedItem.maximumLevel)} | Traspaso: ${updatedItem.traspaso}',
              ),
              leading: Text(
                formatForDisplay(
                    updatedItem.actualStock), // ✅ Updates dynamically
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
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
