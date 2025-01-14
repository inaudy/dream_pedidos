import 'package:flutter/material.dart';
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
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...items.map((item) {
                      final refillQuantity =
                          item.maximumLevel - item.actualStock;
                      return ListTile(
                        title: Text(item.itemName),
                        subtitle: Text(
                            'Actual: ${item.actualStock}, Max: ${item.maximumLevel}, Min: ${item.minimumLevel}'),
                        trailing: Text('Reponer: $refillQuantity'),
                      );
                    }).toList(),
                    const Divider(), // Divider between categories
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
      final category =
          item.categorie ?? 'Uncategorized'; // Use a default category if null
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(item);
    }

    return categorized;
  }
}
