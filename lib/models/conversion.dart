class Conversion {
  final String itemName;
  final double conversionSize;

  Conversion({
    required this.itemName,
    required this.conversionSize,
  });

  // Convert a Conversion object into a Map
  Map<String, dynamic> toMap() {
    return {
      'item_name': itemName,
      'conversion_size': conversionSize,
    };
  }

  // Create a Conversion object from a Map
  factory Conversion.fromMap(Map<String, dynamic> map) {
    return Conversion(
      itemName: map['item_name'],
      conversionSize: map['conversion_size'],
    );
  }
}
