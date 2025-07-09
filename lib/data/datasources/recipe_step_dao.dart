import 'package:sqflite/sqflite.dart';
import '../models/recipe_step_model.dart';
import 'database_helper.dart';

class RecipeStepDao {
  final dbHelper = DatabaseHelper();

  Future<int> insertStep(RecipeStepModel step) async {
    final db = await dbHelper.database;
    return await db.insert('recipe_steps', step.toMap());
  }

  Future<RecipeStepModel?> getStep(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'recipe_steps',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return RecipeStepModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<RecipeStepModel>> getStepsForRecipe(int recipeId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'recipe_steps',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
      orderBy: 'startTime ASC',
    );
    return maps.map((m) => RecipeStepModel.fromMap(m)).toList();
  }

  Future<int> updateStep(RecipeStepModel step) async {
    final db = await dbHelper.database;
    return await db.update(
      'recipe_steps',
      step.toMap(),
      where: 'id = ?',
      whereArgs: [step.id],
    );
  }

  Future<int> deleteStep(int id) async {
    final db = await dbHelper.database;
    return await db.delete('recipe_steps', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStepsForRecipe(int recipeId) async {
    final db = await dbHelper.database;
    return await db.delete(
      'recipe_steps',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
    );
  }
}
