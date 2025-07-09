import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';
import '../viewmodels/recipe_list_viewmodel.dart';
import 'recipe_detail_page.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeListViewModel()..loadRecipes(),
      child: Consumer<RecipeListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Recipes',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.recipes.isEmpty
                ? const Center(
                    child: Text(
                      'No recipes yet. Tap + to add one!',
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: viewModel.recipes.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.white12),
                    itemBuilder: (context, index) {
                      final recipe = viewModel.recipes[index];
                      return ListTile(
                        title: Text(
                          recipe.name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        subtitle:
                            recipe.description != null &&
                                recipe.description!.isNotEmpty
                            ? Text(
                                recipe.description!,
                                style: GoogleFonts.inter(color: Colors.white54),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            await viewModel.deleteRecipe(recipe.id!);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailPage(recipeId: recipe.id!),
                            ),
                          );
                        },
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFF232326),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: _AddRecipeForm(
                      viewModel: viewModel,
                      onAdd: (name, description) async {
                        await viewModel.addRecipe(
                          Recipe(name: name, description: description),
                        );
                        Navigator.of(context).pop();
                        // TODO: Navigate to detail page for new recipe
                      },
                    ),
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add Recipe',
            ),
          );
        },
      ),
    );
  }
}

class _AddRecipeForm extends StatefulWidget {
  final Future<void> Function(String name, String? description) onAdd;
  final RecipeListViewModel viewModel;
  const _AddRecipeForm({required this.onAdd, required this.viewModel});

  @override
  State<_AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<_AddRecipeForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _description;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Recipe',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Recipe Name',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Please enter a name'
                : null,
            onChanged: (value) => setState(() => _name = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => _description = value),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isSubmitting = true);
                      try {
                        await widget.onAdd(
                          _name.trim(),
                          _description?.trim().isEmpty ?? true
                              ? null
                              : _description?.trim(),
                        );
                        debugPrint('Recipe added successfully');
                      } catch (e, stack) {
                        debugPrint('Error adding recipe: $e\n$stack');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: \n$e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isSubmitting = false);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add Recipe'),
          ),
        ],
      ),
    );
  }
}
