import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';
import '../../data/repositories/recipe_repository_impl.dart';

class RecipeListViewModel extends ChangeNotifier {
  final _repo = RecipeRepositoryImpl();
  List<Recipe> _recipes = [];
  bool _isLoading = false;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    _recipes = await _repo.getAllRecipes();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRecipe(int id) async {
    await _repo.deleteRecipe(id);
    await loadRecipes();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _repo.addRecipe(recipe);
    await loadRecipes();
  }
}
