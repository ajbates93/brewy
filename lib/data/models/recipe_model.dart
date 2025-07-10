import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  RecipeModel({
    int? id,
    required String name,
    String? description,
    double? coffeeAmount,
    double? waterAmount,
    bool useMl = false,
  }) : super(
         id: id,
         name: name,
         description: description,
         coffeeAmount: coffeeAmount,
         waterAmount: waterAmount,
         useMl: useMl,
       );

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      coffeeAmount: map['coffee_amount'] != null
          ? (map['coffee_amount'] as num).toDouble()
          : null,
      waterAmount: map['water_amount'] != null
          ? (map['water_amount'] as num).toDouble()
          : null,
      useMl: map['use_ml'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coffee_amount': coffeeAmount,
      'water_amount': waterAmount,
      'use_ml': useMl ? 1 : 0,
    };
  }
}
