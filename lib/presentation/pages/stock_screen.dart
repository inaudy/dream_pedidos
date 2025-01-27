import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_event.dart';
import 'package:dream_pedidos/presentation/blocs/stock_bloc/stock_state.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/presentation/pages/barcodescannerpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StockManagePage extends StatelessWidget {
  const StockManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<StockBloc>().add(LoadStockEvent());

    return Scaffold(
        appBar: AppBar(
          leading: BlocBuilder<StockBloc, StockState>(
            builder: (context, state) {
              if (state is StockLoaded) {
                final items = state.stockItems;
                return IconButton(
                  icon: const Icon(Icons.qr_code_scanner_sharp),
                  onPressed: () {
                    _openBarcodeScanner(context, items);
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<StockBloc, StockState>(
              builder: (context, state) {
                if (state is StockLoaded) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: state.isSearchVisible ? 50 : 0, // Animate height
                    padding: state.isSearchVisible
                        ? const EdgeInsets.all(8)
                        : EdgeInsets.zero,
                    child: state.isSearchVisible
                        ? TextField(
                            onChanged: (value) {
                              context
                                  .read<StockBloc>()
                                  .add(SearchStockEvent(value));
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search, size: 18),
                              labelStyle: const TextStyle(fontSize: 14),
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
            ),
            Expanded(
              child: BlocBuilder<StockBloc, StockState>(
                builder: (context, state) {
                  if (state is StockLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StockLoaded) {
                    final itemsToDisplay = state.filteredStockItems.isNotEmpty
                        ? state.filteredStockItems
                        : state.stockItems;

                    return _buildCategorizedList(context, itemsToDisplay);
                  } else if (state is StockError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(child: Text('No hay datos disponibles.'));
                },
              ),
            ),
          ],
        ));
  }

  /// Build categorized list of stock items
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

  void _openBarcodeScanner(BuildContext context, List<StockItem> items) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BarcodeScannerPage(onScanned: (String barcode) {
                  final matchedItem = items.firstWhere(
                    (item) => item.eanCode == barcode,
                    orElse: () => StockItem(
                        itemName: '',
                        category: '',
                        minimumLevel: 0,
                        maximumLevel: 0,
                        actualStock: 0,
                        eanCode: ''),
                  );
                  if (matchedItem.eanCode != "") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Item encontrado: ${matchedItem.itemName}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                })));
  }

  /// Build individual category section
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

  /// Build individual stock item
  Widget _buildStockItem(BuildContext context, StockItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2.0,
      child: ListTile(
        title: Text(
          item.itemName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              'Mínimo: ${NumberFormat('#.#').format(item.minimumLevel)}\n'
              'Máximo: ${NumberFormat('#.#').format(item.maximumLevel)}'
              'ean_code: ${item.eanCode}',
            ),
          ],
        ),
        leading: Text(
          NumberFormat('#.#').format(item.actualStock),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Categorize stock items by their category
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
