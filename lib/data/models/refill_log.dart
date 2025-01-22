class RefillLog {
  final int id;
  final int salesPointId;
  final String itemName;
  final int refillAmount; // Amount refilled
  final DateTime date;

  RefillLog({
    required this.id,
    required this.salesPointId,
    required this.itemName,
    required this.refillAmount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sales_point_id': salesPointId,
      'item_name': itemName,
      'refill_amount': refillAmount,
      'date': date.toIso8601String(),
    };
  }

  factory RefillLog.fromMap(Map<String, dynamic> map) {
    return RefillLog(
      id: map['id'],
      salesPointId: map['sales_point_id'],
      itemName: map['item_name'],
      refillAmount: map['refill_amount'],
      date: DateTime.parse(map['date']),
    );
  }
}
