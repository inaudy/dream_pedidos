class CocktailRecipe {
  final int? id; // Nullable for new records
  final String itemName;
  final String ingredientName;
  final double quantity;

  CocktailRecipe({
    this.id,
    required this.itemName,
    required this.ingredientName,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'ingredient_name': ingredientName,
      'quantity': quantity,
    };
  }

  factory CocktailRecipe.fromMap(Map<String, dynamic> map) {
    return CocktailRecipe(
      id: map['id'] as int?,
      itemName: map['item_name'],
      ingredientName: map['ingredient_name'],
      quantity: map['quantity'],
    );
  }
}
