import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_step.dart';
import '../../data/repositories/recipe_repository_impl.dart';

class BrewViewModel extends ChangeNotifier {
  final RecipeRepositoryImpl _repo = RecipeRepositoryImpl();
  List<Recipe> _recipes = [];
  Recipe? _selectedRecipe;
  List<RecipeStep> _steps = [];
  bool _isLoading = false;

  List<Recipe> get recipes => _recipes;
  Recipe? get selectedRecipe => _selectedRecipe;
  List<RecipeStep> get steps => _steps;
  bool get isLoading => _isLoading;

  Future<void> loadRecipes({int? selectRecipeId}) async {
    _isLoading = true;
    notifyListeners();
    _recipes = await _repo.getAllRecipes();
    if (_recipes.isNotEmpty) {
      if (selectRecipeId != null) {
        _selectedRecipe = _recipes.firstWhere(
          (r) => r.id == selectRecipeId,
          orElse: () => _recipes.first,
        );
      } else {
        _selectedRecipe ??= _recipes.first;
      }
      await loadStepsForSelectedRecipe();
    } else {
      _selectedRecipe = null;
      _steps = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectRecipe(Recipe recipe) async {
    _selectedRecipe = recipe;
    await loadStepsForSelectedRecipe();
    notifyListeners();
  }

  Future<void> loadStepsForSelectedRecipe() async {
    if (_selectedRecipe != null) {
      _steps = await _repo.getStepsForRecipe(_selectedRecipe!.id!);
    } else {
      _steps = [];
    }
  }
}
