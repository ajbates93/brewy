class Recipe {
  final int? id;
  final String name;
  final String? description;
  final double? coffeeAmount;
  final double? waterAmount;
  final bool useMl; // true for ml, false for grams

  Recipe({
    this.id,
    required this.name,
    this.description,
    this.coffeeAmount,
    this.waterAmount,
    this.useMl = false,
  });

  Recipe copyWith({
    int? id,
    String? name,
    String? description,
    double? coffeeAmount,
    double? waterAmount,
    bool? useMl,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coffeeAmount: coffeeAmount ?? this.coffeeAmount,
      waterAmount: waterAmount ?? this.waterAmount,
      useMl: useMl ?? this.useMl,
    );
  }

  /// Returns the coffee to water ratio (e.g., 1:16.67 for 15g coffee, 250g water)
  double? get coffeeToWaterRatio {
    if (coffeeAmount == null || waterAmount == null || coffeeAmount == 0) {
      return null;
    }
    return waterAmount! / coffeeAmount!;
  }

  /// Returns the water to coffee ratio (e.g., 16.67:1 for 15g coffee, 250g water)
  double? get waterToCoffeeRatio {
    if (coffeeAmount == null || waterAmount == null || coffeeAmount == 0) {
      return null;
    }
    return waterAmount! / coffeeAmount!;
  }

  /// Returns the unit string based on useMl flag
  String get unit => useMl ? 'ml' : 'g';
}
