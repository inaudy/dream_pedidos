/*import 'package:dream_pedidos/blocs/stock_bloc/stock_bloc.dart';
import 'package:dream_pedidos/blocs/stock_bloc/stock_event.dart';
import 'package:dream_pedidos/models/stock_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StockEditPage extends StatefulWidget {
  final StockItem? item;

  const StockEditPage({Key? key, this.item}) : super(key: key);

  @override
  State<StockEditPage> createState() => _StockEditPageState();
}

class _StockEditPageState extends State<StockEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _actualQtyController = TextEditingController();
  final TextEditingController _minQtyController = TextEditingController();
  final TextEditingController _maxQtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.itemName;
      _actualQtyController.text = widget.item!.actualStock.toString();
      _minQtyController.text = widget.item!.minimumLevel.toString();
      _maxQtyController.text = widget.item!.maximumLevel.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.item == null ? 'Add Stock' : 'Edit Stock')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              readOnly: widget.item != null,
            ),
            TextField(
              controller: _actualQtyController,
              decoration: const InputDecoration(labelText: 'Actual Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _minQtyController,
              decoration: const InputDecoration(labelText: 'Minimum Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maxQtyController,
              decoration: const InputDecoration(labelText: 'Maximum Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final stockItem = StockItem(
                  itemName: _nameController.text,
                  actualStock: int.parse(_actualQtyController.text),
                  minimumLevel: int.parse(_minQtyController.text),
                  maximumLevel: int.parse(_maxQtyController.text),
                  categorie: 
                );
                if (widget.item == null) {
                  context.read<StockBloc>().add(AddStockEvent(stockItem));
                } else {
                  context.read<StockBloc>().add(UpdateStockEvent(stockItem));
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
*/