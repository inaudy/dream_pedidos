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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Pedidos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPdf(context),
          ),
        ],
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
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Align to the right
          children: [
            TextButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Enviar'), // Add the text next to the icon
              onPressed: () => _bulkUpdateStock(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Icon and text color
              ),
            ),
            const SizedBox(width: 16), // Add some padding at the end
          ],
        ),
      ),
    );
  }

  Future<Map<String, List<StockItem>>> _getCategorizedRefillReport() async {
    final allStockItems = await stockRepository.getAllStockItems();

    final refillItems = allStockItems.where((item) {
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
    final cubit = context.read<ItemSelectionCubit>();
    final selectedItems = cubit.state.selectedItems;

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay items seleccionados')),
      );
      return;
    }

    for (final item in selectedItems) {
      final newStock = item.maximumLevel;
      final updatedItem = item.copyWith(actualStock: newStock);
      await stockRepository.updateStockItem(updatedItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Stock actualizado para los items seleccionados')),
    );
  }

  void _exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    final categorizedData = await _getCategorizedRefillReport();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: categorizedData.keys.map((category) {
                final items = categorizedData[category]!;
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      category.isEmpty ? 'Uncategorized' : category,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...items.map((item) {
                      final refillQuantity =
                          item.maximumLevel - item.actualStock;
                      return pw.Text(
                        '${item.itemName}: Cantidad ${refillQuantity}',
                        style: const pw.TextStyle(fontSize: 12),
                      );
                    }),
                    pw.Divider(),
                  ],
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
