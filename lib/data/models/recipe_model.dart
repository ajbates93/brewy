import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  RecipeModel({int? id, required String name, String? description})
    : super(id: id, name: name, description: description);

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }
}
