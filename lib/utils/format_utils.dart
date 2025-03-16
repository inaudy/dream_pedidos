import 'package:intl/intl.dart';

String formatForDisplay(double value) {
  if (value % 1 == 0) {
    return NumberFormat('#,##0', 'es_ES').format(value);
  } else {
    return NumberFormat('#,##0.##', 'es_ES').format(value);
  }
}

double formatForSave(String input) {
  String normalizedInput = input.replaceAll(',', '.');
  return double.tryParse(normalizedInput) ?? 0.0;
}
