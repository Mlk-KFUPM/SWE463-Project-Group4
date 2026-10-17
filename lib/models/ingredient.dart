/// One line in a recipe's ingredient list, for example "1.5 kg Chicken".
class Ingredient {
  final double quantity;
  final String unit;
  final String name;

  const Ingredient({
    required this.quantity,
    required this.unit,
    required this.name,
  });

  /// Quantity for a different number of servings.
  /// Used by the servings stepper on the recipe details screen (S4).
  double scaledQuantity(int baseServings, int targetServings) {
    if (baseServings <= 0) return quantity;
    return quantity * targetServings / baseServings;
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String? ?? '',
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'unit': unit,
      'name': name,
    };
  }
}
