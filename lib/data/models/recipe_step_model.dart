import '../../domain/entities/recipe_step.dart';

class RecipeStepModel extends RecipeStep {
  RecipeStepModel({
    int? id,
    required int recipeId,
    required int startTime,
    int? endTime,
    required String description,
  }) : super(
         id: id,
         recipeId: recipeId,
         startTime: startTime,
         endTime: endTime,
         description: description,
       );

  factory RecipeStepModel.fromMap(Map<String, dynamic> map) {
    return RecipeStepModel(
      id: map['id'] as int?,
      recipeId: map['recipeId'] as int,
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int?,
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
    };
  }
}
