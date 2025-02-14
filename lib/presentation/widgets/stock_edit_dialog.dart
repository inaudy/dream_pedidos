import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/presentation/blocs/stock_management/stock_management_bloc.dart';
import 'package:dream_pedidos/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditItemDialog extends StatefulWidget {
  final StockItem item;
  final String labelText;

  const EditItemDialog(
      {super.key, required this.item, required this.labelText});

  static void show(BuildContext context, StockItem item, String labelText) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StockManagementBloc>(),
        child: EditItemDialog(
          item: item,
          labelText: labelText,
        ),
      ),
    );
  }

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _stockController;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: formatForDisplay(widget.item.actualStock),
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  void _updateStock(BuildContext context) {
    double updatedStock = parseInput(_stockController.text);

    if (updatedStock >= 0) {
      context.read<StockManagementBloc>().add(
            UpdateStockItemEvent(
                widget.item.copyWith(actualStock: updatedStock)),
          );
      Navigator.pop(context);
    } else {
      setState(() => _isValid = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.itemName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: _stockController,
          decoration: InputDecoration(
            labelText: widget.labelText,
            errorText: _isValid ? null : 'Ingrese un número válido',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[800]),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _updateStock(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // 🔵 Updated color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  double parseInput(String input) {
    String normalizedInput = input.replaceAll(',', '.'); // Convert comma to dot
    return double.tryParse(normalizedInput) ?? 0.0;
  }
}
