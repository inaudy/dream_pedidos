import 'package:dream_pedidos/utils/format_utils.dart';
import 'package:flutter/material.dart';

class EditStockDialog extends StatefulWidget {
  final String title;
  final double initialActualStock;
  final double initialMin;
  final double initialMax;
  final void Function(double newActual, double newMin, double newMax) onSave;

  const EditStockDialog({
    Key? key,
    required this.title,
    required this.initialActualStock,
    required this.initialMin,
    required this.initialMax,
    required this.onSave,
  }) : super(key: key);

  /// Use this static method to show the dialog.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required double initialActualStock,
    required double initialMin,
    required double initialMax,
    required void Function(double newActual, double newMin, double newMax)
        onSave,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => EditStockDialog(
        title: title,
        initialActualStock: initialActualStock,
        initialMin: initialMin,
        initialMax: initialMax,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditStockDialog> createState() => _EditStockDialogState();
}

class _EditStockDialogState extends State<EditStockDialog> {
  late TextEditingController _actualController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _actualController = TextEditingController(
        text: formatForDisplay(widget.initialActualStock));
    _minController =
        TextEditingController(text: formatForDisplay(widget.initialMin));
    _maxController =
        TextEditingController(text: formatForDisplay(widget.initialMax));
  }

  @override
  void dispose() {
    _actualController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final double newActual = _parseInput(_actualController.text);
    final double newMin = _parseInput(_minController.text);
    final double newMax = _parseInput(_maxController.text);
    if (newActual >= 0 && newMin >= 0 && newMax >= 0) {
      widget.onSave(newActual, newMin, newMax);
      Navigator.pop(context);
    } else {
      setState(() => _isValid = false);
    }
  }

  double _parseInput(String input) {
    final normalized = input.replaceAll(',', '.');
    return double.tryParse(normalized) ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Actual Stock Field
            TextFormField(
              controller: _actualController,
              decoration: InputDecoration(
                labelText: 'Actual',
                errorText: _isValid ? null : 'Ingrese un número válido',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            // Minimum Level Field
            TextFormField(
              controller: _minController,
              decoration: InputDecoration(
                labelText: 'Minimo',
                errorText: _isValid ? null : 'Ingrese un número válido',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            // Maximum Level Field
            TextFormField(
              controller: _maxController,
              decoration: InputDecoration(
                labelText: 'Maximo',
                errorText: _isValid ? null : 'Ingrese un número válido',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[800]),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
