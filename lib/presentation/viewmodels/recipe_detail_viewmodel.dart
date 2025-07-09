import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_step.dart';
import '../../data/repositories/recipe_repository_impl.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  final RecipeRepositoryImpl _repo = RecipeRepositoryImpl();
  Recipe? _recipe;
  List<RecipeStep> _steps = [];
  bool _isLoading = false;

  Recipe? get recipe => _recipe;
  List<RecipeStep> get steps => _steps;
  bool get isLoading => _isLoading;

  Future<void> loadRecipe(int recipeId) async {
    _isLoading = true;
    notifyListeners();
    _recipe = await _repo.getRecipe(recipeId);
    _steps = await _repo.getStepsForRecipe(recipeId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStep(RecipeStep step) async {
    await _repo.addStep(step);
    await loadRecipe(_recipe!.id!);
  }

  Future<void> updateStep(RecipeStep step) async {
    await _repo.updateStep(step);
    await loadRecipe(_recipe!.id!);
  }

  Future<void> deleteStep(int stepId) async {
    await _repo.deleteStep(stepId);
    await loadRecipe(_recipe!.id!);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _repo.updateRecipe(recipe);
    if (recipe.id != null) {
      await loadRecipe(recipe.id!);
    }
  }
}
