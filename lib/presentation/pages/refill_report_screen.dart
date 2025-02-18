import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/item_selection_cubit.dart';
import 'package:dream_pedidos/presentation/widgets/stock_edit_dialog.dart';
import 'package:dream_pedidos/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RefillReportPage extends StatefulWidget {
  const RefillReportPage({super.key});

  @override
  State<RefillReportPage> createState() => _RefillReportPageState();
}

class _RefillReportPageState extends State<RefillReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<StockManagementBloc>().add(LoadStockEvent());
  }

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
            final filteredStockItems = _filterStockItems(state.stockItems);
            if (filteredStockItems.isEmpty) {
              return const Center(
                child: Text('No hay productos para reponer',
                    style: TextStyle(fontSize: 16)),
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

  /// Filters stock items that need refilling.
  List<StockItem> _filterStockItems(List<StockItem> stockItems) {
    return stockItems.where((item) {
      return item.actualStock <= item.minimumLevel &&
          !(item.actualStock == item.minimumLevel &&
              item.minimumLevel == item.maximumLevel);
    }).toList();
  }

  /// Shows error messages.
  Widget _buildErrorMessage(String? message) {
    return Center(
      child: Text(
        'Error: ${message ?? "Error desconocido"}',
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the stock list with categorized items.
  Widget _buildStockList(BuildContext context, List<StockItem> stockItems) {
    final categorizedData = _categorizeStockItems(stockItems);
    return ListView(
      children: categorizedData.entries.map((entry) {
        return _buildCategorySection(context, entry.key, entry.value);
      }).toList(),
    );
  }

  /// Groups items by category.
  Map<String, List<StockItem>> _categorizeStockItems(
      List<StockItem> stockItems) {
    final Map<String, List<StockItem>> categories = {};
    for (var item in stockItems) {
      final category = item.category.isEmpty ? 'Sin Categoría' : item.category;
      categories.putIfAbsent(category, () => []).add(item);
    }
    return categories;
  }

  /// Builds a section for each category.
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
                    color: Colors.white),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildStockItem(context, item)),
      ],
    );
  }

  Widget _buildStockItem(BuildContext context, StockItem item) {
    final itemSelectionState = context.watch<ItemSelectionCubit>().state;

    final double defaultRefill = item.maximumLevel - item.actualStock;

    final double currentRefill =
        itemSelectionState.quantities[item.itemName] ?? defaultRefill;

    final int errorPercentage = item.errorPercentage;
    final double adjustedRefillQuantity = errorPercentage > 0
        ? currentRefill * (1 + (errorPercentage / 100))
        : currentRefill;

    return Slidable(
      key: ValueKey(item.itemName),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              // Use the dialog to update the refill quantity.
              EditValueDialog.show(
                context,
                title: 'Editar cantidad a reponer para ${item.itemName}',
                labelText: 'Cantidad a reponer',
                initialValue: currentRefill,
                onSave: (newRefill) {
                  // Update the stored quantity for this item.
                  context
                      .read<ItemSelectionCubit>()
                      .updateItemQuantity(item.itemName, newRefill);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          // Leading widget now simply displays the adjusted refill quantity.
          leading: Text(
            formatForDisplay(adjustedRefillQuantity),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          title: Text(
            item.itemName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Actual: ${formatForDisplay(item.actualStock)} | Min: ${formatForDisplay(item.minimumLevel)} | Max: ${formatForDisplay(item.maximumLevel)}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Checkbox(
            value: itemSelectionState.selectedItems.contains(item),
            onChanged: (selected) {
              if (selected == true) {
                context.read<ItemSelectionCubit>().selectItem(item);
              } else {
                context.read<ItemSelectionCubit>().deselectItem(item);
              }
            },
          ),
        ),
      ),
    );
  }

  /// Bottom bar to submit selected items.
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
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bulkUpdateStock(BuildContext context) async {
    final itemSelectionCubit = context.read<ItemSelectionCubit>();
    final stockBloc = context.read<StockManagementBloc>();
    final selectedItems = itemSelectionCubit.state.selectedItems;

    if (selectedItems.isEmpty) {
      _showSnackBar(context, 'No hay items seleccionados');
      return;
    }

    final Map<String, double> refillMap = {};
    final List<StockItem> updatedItems = [];
    for (final item in selectedItems) {
      // Retrieve the raw refill value (from the cubit or computed as (max - actual)).
      final double rawRefill =
          itemSelectionCubit.state.quantities[item.itemName] ??
              (item.maximumLevel - item.actualStock);
      refillMap[item.itemName] = rawRefill;
      // Calculate the new actual stock.
      final double newActualStock = item.actualStock + rawRefill;
      final updatedItem = item.copyWith(actualStock: newActualStock);
      updatedItems.add(updatedItem);
    }

    // Dispatch the bulk update event with the updated items and refill map.
    stockBloc.add(BulkUpdateStockEvent(updatedItems, refillMap));

    // Clear selected items.
    itemSelectionCubit.clearSelection();

    // Do not reload the entire list; the bulk update event handler already emits a state with the updated list.
    if (context.mounted) {
      //_showSnackBar(context, 'Stock actualizado para los items seleccionados');
    }
  }

  /// Shows a Snackbar message.
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
