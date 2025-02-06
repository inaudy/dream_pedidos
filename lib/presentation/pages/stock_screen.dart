import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/presentation/cubit/edit_stock_cubit.dart';
import 'package:dream_pedidos/presentation/cubit/stock_search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class StockManagePage extends StatelessWidget {
  const StockManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockManagementBloc, StockManagementState>(
      listener: (context, state) {
        if (state is StockEditDialogState) {
          _showStockEditDialog(context, state.stockItem);
        }
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Listen for StockLoaded updates after sync/upload.
            _buildSearchBar(context),
            // Stock List (Filtered & Categorized)
            Expanded(
              child: BlocBuilder<StockManagementBloc, StockManagementState>(
                builder: (context, stockState) {
                  if (stockState is StockLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (stockState is StockLoaded) {
                    final searchQuery =
                        context.watch<StockSearchCubit>().state.toLowerCase();
                    final filteredStock =
                        _applySearchFilter(stockState.stockItems, searchQuery);
                    return _buildCategorizedList(context, filteredStock);
                  } else if (stockState is StockError) {
                    return Center(
                      child: Text(
                        'Error: ${stockState.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(child: Text('No hay datos disponibles.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockEditDialog(BuildContext context, StockItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider(
          create: (_) => StockItemEditCubit(item),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: Text(item.itemName),
                content: BlocBuilder<StockItemEditCubit, StockItemEditState>(
                  builder: (context, state) {
                    return TextFormField(
                      initialValue: state.actualStock.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Stock Actual'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        context
                            .read<StockItemEditCubit>()
                            .actualStockChanged(value);
                      },
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final updatedItem = StockItem(
                        itemName: item.itemName,
                        minimumLevel: item.minimumLevel,
                        maximumLevel: item.maximumLevel,
                        actualStock: context
                            .read<StockItemEditCubit>()
                            .state
                            .actualStock,
                        category: item.category,
                        traspaso: item.traspaso,
                        eanCode: item.eanCode,
                        errorPercentage: item.errorPercentage,
                      );

                      // Dispatch the update event to the Bloc
                      context
                          .read<StockManagementBloc>()
                          .add(UpdateStockItemEvent(updatedItem));
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Build the search bar that toggles its visibility.
  Widget _buildSearchBar(BuildContext context) {
    return BlocBuilder<StockManagementBloc, StockManagementState>(
      builder: (context, state) {
        if (state is StockLoaded) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: state.isSearchVisible ? 50 : 0,
            padding: state.isSearchVisible
                ? const EdgeInsets.all(8)
                : EdgeInsets.zero,
            child: state.isSearchVisible
                ? TextField(
                    onChanged: (value) {
                      context.read<StockSearchCubit>().updateSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: 'Buscar...',
                      hintStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                    ),
                    style: const TextStyle(fontSize: 14),
                  )
                : null,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Apply search filtering logic.
  List<StockItem> _applySearchFilter(
      List<StockItem> stockItems, String searchQuery) {
    if (searchQuery.isEmpty) return stockItems;
    final queryWords = searchQuery.toLowerCase().split(' ');
    return stockItems.where((item) {
      final itemName = item.itemName.toLowerCase();
      return queryWords.every((word) => itemName.contains(word));
    }).toList();
  }

  /// Build categorized stock list.
  Widget _buildCategorizedList(
      BuildContext context, List<StockItem> stockItems) {
    final categorizedData = _categorizeStockItems(stockItems);
    if (categorizedData.isEmpty) {
      return const Center(
        child: Text(
          'No hay stock disponible para mostrar.',
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

  /// Build an individual category section.
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

  /// Build an individual stock item with a slide-to-edit action.
  Widget _buildStockItem(BuildContext context, StockItem item) {
    // Capture the parent's context that has global providers.
    final globalContext = context;
    return Slidable(
      key: ValueKey(item.itemName),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (ctx) {
              // Use the parent's context (globalContext) for showDialog.
              showDialog(
                context: globalContext,
                builder: (BuildContext dialogContext) {
                  return BlocProvider<StockItemEditCubit>(
                    create: (_) => StockItemEditCubit(item),
                    // Wrap AlertDialog in a Builder so its context is under the BlocProvider.
                    child: Builder(
                      builder: (context) {
                        return AlertDialog(
                          title: Text(item.itemName),
                          content: BlocBuilder<StockItemEditCubit,
                              StockItemEditState>(
                            builder: (context, state) {
                              return SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Field for editing Actual Stock.
                                    TextFormField(
                                      initialValue: NumberFormat('#.#')
                                          .format(state.actualStock),
                                      decoration: const InputDecoration(
                                        labelText: 'Actual Stock',
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => context
                                          .read<StockItemEditCubit>()
                                          .actualStockChanged(value),
                                    ),
                                    // Field for editing Error Percentage.
                                    TextFormField(
                                      initialValue:
                                          state.errorPercentage.toString(),
                                      decoration: const InputDecoration(
                                        labelText: 'Error %',
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => context
                                          .read<StockItemEditCubit>()
                                          .errorPercentageChanged(value),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: const Text('Salir'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final updatedItem = StockItem(
                                  itemName: item.itemName,
                                  minimumLevel: item.minimumLevel,
                                  maximumLevel: item.maximumLevel,
                                  actualStock: context
                                      .read<StockItemEditCubit>()
                                      .state
                                      .actualStock,
                                  category: item.category,
                                  traspaso: context
                                      .read<StockItemEditCubit>()
                                      .state
                                      .traspaso,
                                  eanCode: item.eanCode,
                                  errorPercentage: context
                                      .read<StockItemEditCubit>()
                                      .state
                                      .errorPercentage,
                                );
                                // Dispatch the update event to the global StockManagementBloc.
                                globalContext
                                    .read<StockManagementBloc>()
                                    .add(UpdateStockItemEvent(updatedItem));
                                Navigator.of(dialogContext).pop();
                              },
                              child: const Text('Guardar'),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
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
            'Mínimo: ${item.minimumLevel} | Máximo: ${item.maximumLevel} | Trasp: ${item.traspaso} | %Error: ${item.errorPercentage}',
          ),
          leading: Text(
            '${item.actualStock}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// Categorize stock items by category.
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
