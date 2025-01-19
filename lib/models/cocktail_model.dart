class Cocktail {
  final String name;
  final Map<String, double> recipe; // product_stock_name and size

  Cocktail({
    required this.name,
    required this.recipe,
  });

  // Convert Cocktail to a map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  // Factory method to create a Cocktail from a map and recipe rows
  factory Cocktail.fromMap(
      Map<String, dynamic> map, List<Map<String, dynamic>> recipeRows) {
    return Cocktail(
      name: map['name'] as String,
      recipe: {
        for (var row in recipeRows)
          row['product_stock_name'] as String: row['size'] as double,
      },
    );
  }
}
