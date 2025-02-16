import 'package:dream_pedidos/utils/format_utils.dart';
import 'package:flutter/material.dart';

class EditValueDialog extends StatefulWidget {
  final String title;
  final String labelText;
  final double initialValue;
  final void Function(double newValue) onSave;

  const EditValueDialog({
    Key? key,
    required this.title,
    required this.labelText,
    required this.initialValue,
    required this.onSave,
  }) : super(key: key);

  /// Call this static method to show the dialog.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String labelText,
    required double initialValue,
    required void Function(double newValue) onSave,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => EditValueDialog(
        title: title,
        labelText: labelText,
        initialValue: initialValue,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<EditValueDialog> {
  late TextEditingController _controller;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided initial value.
    _controller =
        TextEditingController(text: formatForDisplay(widget.initialValue));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final double newValue = _parseInput(_controller.text);
    if (newValue >= 0) {
      widget.onSave(newValue);
      Navigator.pop(context);
    } else {
      setState(() => _isValid = false);
    }
  }

  double _parseInput(String input) {
    // Replace comma with dot to normalize decimals.
    final normalized = input.replaceAll(',', '.');
    return double.tryParse(normalized) ?? -1; // return -1 if parsing fails.
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.labelText,
            errorText: _isValid ? null : 'Ingrese un número válido',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
