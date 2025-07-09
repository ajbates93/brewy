import 'package:sqflite/sqflite.dart';
import '../models/recipe_model.dart';
import 'database_helper.dart';

class RecipeDao {
  final dbHelper = DatabaseHelper();

  Future<int> insertRecipe(RecipeModel recipe) async {
    final db = await dbHelper.database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<RecipeModel?> getRecipe(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return RecipeModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<RecipeModel>> getAllRecipes() async {
    final db = await dbHelper.database;
    final maps = await db.query('recipes');
    return maps.map((m) => RecipeModel.fromMap(m)).toList();
  }

  Future<int> updateRecipe(RecipeModel recipe) async {
    final db = await dbHelper.database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await dbHelper.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}
