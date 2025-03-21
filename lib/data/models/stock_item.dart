class StockItem {
  final String itemName;
  final double actualStock;
  final double minimumLevel;
  final double maximumLevel;
  final String category;
  final String? traspaso;
  final String? eanCode;
  final int errorPercentage;

  StockItem({
    required this.itemName,
    required this.actualStock,
    required this.minimumLevel,
    required this.maximumLevel,
    required this.category,
    this.traspaso,
    this.eanCode,
    required this.errorPercentage,
  });

  // Method to create a copy of this StockItem with updated values
  StockItem copyWith({
    String? itemName,
    double? actualStock,
    double? minimumLevel,
    double? maximumLevel,
    String? category,
    String? traspaso,
    String? eanCode,
    int? errorPercentage,
  }) {
    return StockItem(
      itemName: itemName ?? this.itemName,
      actualStock: actualStock ?? this.actualStock,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      maximumLevel: maximumLevel ?? this.maximumLevel,
      category: category ?? this.category,
      traspaso: traspaso ?? this.traspaso,
      eanCode: eanCode ?? this.eanCode,
      errorPercentage: errorPercentage ?? this.errorPercentage,
    );
  }

  // Method to convert the StockItem to a map (useful for databases)
  Map<String, dynamic> toMap() {
    return {
      'item_name': itemName,
      'actual_stock': actualStock,
      'minimum_level': minimumLevel,
      'maximum_level': maximumLevel,
      'category': category,
      'traspaso': traspaso,
      'ean_code': eanCode,
      'error_percentage': errorPercentage,
    };
  }

  // Factory method to create a StockItem from a map (useful for databases)
  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      itemName: map['item_name'],
      actualStock: map['actual_stock'],
      minimumLevel: map['minimum_level'],
      maximumLevel: map['maximum_level'],
      category: map['category'],
      traspaso: map['traspaso'],
      eanCode: map['ean_code'],
      errorPercentage:
          (map['error_percentage'] as num?)?.toInt() ?? 0, // Default 0.0%
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StockItem) return false;
    return itemName == other.itemName && category == other.category;
  }

  @override
  int get hashCode => itemName.hashCode ^ category.hashCode;
}
