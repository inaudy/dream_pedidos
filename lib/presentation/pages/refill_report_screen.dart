import 'package:dream_pedidos/blocs/cubit/item_selection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/models/stock_item.dart';
import '/services/repositories/stock_repository.dart';

class RefillReportPage extends StatelessWidget {
  final StockRepository stockRepository = StockRepository();

  RefillReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refill Report'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<StockItem>>>(
        future: _getCategorizedRefillReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay nada para reponer'),
            );
          } else {
            final categorizedData = snapshot.data!;
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
                                'Cant: $refillQuantity',
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
                      color: Colors.black45, // Main divider after each category
                      thickness: 1,
                    ),
                  ],
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, List<StockItem>>> _getCategorizedRefillReport() async {
    final allStockItems = await stockRepository.getAllStockItems();

    // Filter items that need refilling
    final refillItems = allStockItems.where((item) {
      return item.actualStock < item.minimumLevel;
    });

    // Group by category
    final Map<String, List<StockItem>> categorized = {};
    for (var item in refillItems) {
      final category = item.categorie; // Use a default category if null
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(item);
    }

    return categorized;
  }
}
