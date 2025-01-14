class SalesData {
  final DateTime date;
  final String itemName;
  final double salesVolume;

  SalesData({
    required this.date,
    required this.itemName,
    required this.salesVolume,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': date,
      'name': itemName,
      'location': salesVolume,
    };
  }

  factory SalesData.fromMap(Map<String, dynamic> map) {
    return SalesData(
      date: map['id'],
      itemName: map['name'],
      salesVolume: map['location'],
    );
  }
}
