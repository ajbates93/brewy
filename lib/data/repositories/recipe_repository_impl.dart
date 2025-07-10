import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_step.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_dao.dart';
import '../datasources/recipe_step_dao.dart';
import '../models/recipe_model.dart';
import '../models/recipe_step_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeDao recipeDao;
  final RecipeStepDao stepDao;

  RecipeRepositoryImpl({RecipeDao? recipeDao, RecipeStepDao? stepDao})
    : recipeDao = recipeDao ?? RecipeDao(),
      stepDao = stepDao ?? RecipeStepDao();

  @override
  Future<int> addRecipe(Recipe recipe) async {
    return await recipeDao.insertRecipe(
      RecipeModel(
        name: recipe.name,
        description: recipe.description,
        coffeeAmount: recipe.coffeeAmount,
        waterAmount: recipe.waterAmount,
        useMl: recipe.useMl,
      ),
    );
  }

  @override
  Future<Recipe?> getRecipe(int id) async {
    return await recipeDao.getRecipe(id);
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return await recipeDao.getAllRecipes();
  }

  @override
  Future<int> updateRecipe(Recipe recipe) async {
    return await recipeDao.updateRecipe(
      RecipeModel(
        id: recipe.id,
        name: recipe.name,
        description: recipe.description,
        coffeeAmount: recipe.coffeeAmount,
        waterAmount: recipe.waterAmount,
        useMl: recipe.useMl,
      ),
    );
  }

  @override
  Future<int> deleteRecipe(int id) async {
    return await recipeDao.deleteRecipe(id);
  }

  @override
  Future<int> addStep(RecipeStep step) async {
    return await stepDao.insertStep(
      RecipeStepModel(
        recipeId: step.recipeId,
        startTime: step.startTime,
        endTime: step.endTime,
        description: step.description,
      ),
    );
  }

  @override
  Future<RecipeStep?> getStep(int id) async {
    return await stepDao.getStep(id);
  }

  @override
  Future<List<RecipeStep>> getStepsForRecipe(int recipeId) async {
    return await stepDao.getStepsForRecipe(recipeId);
  }

  @override
  Future<int> updateStep(RecipeStep step) async {
    return await stepDao.updateStep(
      RecipeStepModel(
        id: step.id,
        recipeId: step.recipeId,
        startTime: step.startTime,
        endTime: step.endTime,
        description: step.description,
      ),
    );
  }

  @override
  Future<int> deleteStep(int id) async {
    return await stepDao.deleteStep(id);
  }

  @override
  Future<int> deleteStepsForRecipe(int recipeId) async {
    return await stepDao.deleteStepsForRecipe(recipeId);
  }
}
