import '../entities/recipe.dart';
import '../entities/recipe_step.dart';

abstract class RecipeRepository {
  Future<int> addRecipe(Recipe recipe);
  Future<Recipe?> getRecipe(int id);
  Future<List<Recipe>> getAllRecipes();
  Future<int> updateRecipe(Recipe recipe);
  Future<int> deleteRecipe(int id);

  Future<int> addStep(RecipeStep step);
  Future<RecipeStep?> getStep(int id);
  Future<List<RecipeStep>> getStepsForRecipe(int recipeId);
  Future<int> updateStep(RecipeStep step);
  Future<int> deleteStep(int id);
  Future<int> deleteStepsForRecipe(int recipeId);
}
