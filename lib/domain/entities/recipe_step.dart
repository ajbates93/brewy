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
}
