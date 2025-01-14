class StockItem {
  final String itemName;
  final int actualStock;
  final int minimumLevel;
  final int maximumLevel;
  final String categorie;

  StockItem({
    required this.itemName,
    required this.actualStock,
    required this.minimumLevel,
    required this.maximumLevel,
    required this.categorie,
  });

  Map<String, dynamic> toMap() {
    return {
      'item_name': itemName,
      'actual_stock': actualStock,
      'minimum_level': minimumLevel,
      'maximum_level': maximumLevel,
      'categorie': categorie,
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      itemName: map['item_name'],
      actualStock: map['actual_stock'],
      minimumLevel: map['minimum_level'],
      maximumLevel: map['maximum_level'],
      categorie: map['categorie'],
    );
  }
}
