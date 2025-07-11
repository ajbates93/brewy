class RecipeStep {
  final int? id;
  final int recipeId;
  final int startTime;
  final int? endTime;
  final String description;

  RecipeStep({
    this.id,
    required this.recipeId,
    required this.startTime,
    this.endTime,
    required this.description,
  });

  RecipeStep copyWith({
    int? id,
    int? recipeId,
    int? startTime,
    int? endTime,
    String? description,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
    );
  }
}
