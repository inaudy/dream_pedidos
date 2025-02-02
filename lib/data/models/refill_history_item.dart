class RefillHistoryItem {
  final int id;
  final String itemName;
  final double refillQuantity;
  final DateTime refillDate;

  RefillHistoryItem({
    required this.id,
    required this.itemName,
    required this.refillQuantity,
    required this.refillDate,
  });

  factory RefillHistoryItem.fromMap(Map<String, dynamic> map) {
    return RefillHistoryItem(
      id: map['id'],
      itemName: map['item_name'],
      refillQuantity: map['refill_quantity'],
      refillDate: DateTime.parse(map['refill_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'refill_quantity': refillQuantity,
      'refill_date': refillDate.toIso8601String(),
    };
  }
}
