import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_step.dart';
import '../viewmodels/recipe_detail_viewmodel.dart';

class RecipeDetailPage extends StatelessWidget {
  final int recipeId;
  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeDetailViewModel()..loadRecipe(recipeId),
      child: Consumer<RecipeDetailViewModel>(
        builder: (context, viewModel, child) {
          final recipe = viewModel.recipe;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                recipe?.name ?? '',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              centerTitle: true,
              actions: recipe == null
                  ? null
                  : [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        tooltip: 'Edit Recipe',
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
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                    24,
                              ),
                              child: _EditRecipeForm(
                                initialName: recipe.name,
                                initialDescription: recipe.description,
                                onSave: (name, description) async {
                                  await viewModel.updateRecipe(
                                    recipe.copyWith(
                                      name: name,
                                      description: description,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : recipe == null
                ? const Center(
                    child: Text(
                      'Recipe not found',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe.description != null &&
                            recipe.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              recipe.description!,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        Text(
                          'Steps',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: viewModel.steps.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No steps yet. Tap + to add one!',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: viewModel.steps.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 1,
                                    color: Colors.white12,
                                  ),
                                  itemBuilder: (context, index) {
                                    final step = viewModel.steps[index];
                                    return ListTile(
                                      title: Text(
                                        step.description,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Start: ${step.startTime}s  End: ${step.endTime?.toString() ?? '—'}s',
                                        style: GoogleFonts.inter(
                                          color: Colors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () async {
                                              await showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: const Color(
                                                  0xFF232326,
                                                ),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  24,
                                                                ),
                                                          ),
                                                    ),
                                                builder: (context) => Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 24,
                                                    right: 24,
                                                    top: 24,
                                                    bottom:
                                                        MediaQuery.of(
                                                          context,
                                                        ).viewInsets.bottom +
                                                        24,
                                                  ),
                                                  child: _EditStepForm(
                                                    initialStartTime:
                                                        _formatStepTime(
                                                          step.startTime,
                                                        ),
                                                    initialEndTime:
                                                        step.endTime != null
                                                        ? _formatStepTime(
                                                            step.endTime!,
                                                          )
                                                        : '',
                                                    initialDescription:
                                                        step.description,
                                                    onSave:
                                                        (
                                                          start,
                                                          end,
                                                          desc,
                                                        ) async {
                                                          await viewModel
                                                              .updateStep(
                                                                RecipeStep(
                                                                  id: step.id,
                                                                  recipeId: step
                                                                      .recipeId,
                                                                  startTime:
                                                                      start,
                                                                  endTime: end,
                                                                  description:
                                                                      desc,
                                                                ),
                                                              );
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () async {
                                              await viewModel.deleteStep(
                                                step.id!,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final viewModel = Provider.of<RecipeDetailViewModel>(
                  context,
                  listen: false,
                );
                // Determine default start time
                String? defaultStartTime;
                if (viewModel.steps.isEmpty) {
                  defaultStartTime = '00:00';
                } else {
                  final lastStep = viewModel.steps.last;
                  if (lastStep.endTime != null) {
                    final minutes = (lastStep.endTime! ~/ 60)
                        .toString()
                        .padLeft(2, '0');
                    final seconds = (lastStep.endTime! % 60).toString().padLeft(
                      2,
                      '0',
                    );
                    defaultStartTime = '$minutes:$seconds';
                  } else {
                    defaultStartTime = '';
                  }
                }
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
                    child: _AddStepForm(
                      initialStartTime: defaultStartTime,
                      onAdd: (start, end, desc) async {
                        await viewModel.addStep(
                          RecipeStep(
                            recipeId: viewModel.recipe!.id!,
                            startTime: start,
                            endTime: end,
                            description: desc,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add Step',
            ),
          );
        },
      ),
    );
  }
}

class _AddStepForm extends StatefulWidget {
  final Future<void> Function(int start, int? end, String desc) onAdd;
  final String? initialStartTime;
  const _AddStepForm({required this.onAdd, this.initialStartTime});

  @override
  State<_AddStepForm> createState() => _AddStepFormState();
}

class _AddStepFormState extends State<_AddStepForm> {
  final _formKey = GlobalKey<FormState>();
  String _startTimeStr = '';
  String _endTimeStr = '';
  int? _startTime;
  int? _endTime;
  String _description = '';
  bool _isSubmitting = false;

  int? _parseTime(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length != 2) return null;
      final minutes = int.tryParse(parts[0]);
      final seconds = int.tryParse(parts[1]);
      if (minutes == null ||
          seconds == null ||
          minutes < 0 ||
          seconds < 0 ||
          seconds > 59)
        return null;
      return minutes * 60 + seconds;
    } else {
      final seconds = int.tryParse(trimmed);
      if (seconds == null || seconds < 0) return null;
      return seconds;
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimeStr = widget.initialStartTime ?? '';
    _startTime = _parseTime(_startTimeStr);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Step',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _startTimeStr,
            decoration: const InputDecoration(
              labelText: 'Start Time (MM:SS or seconds)',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.text,
            validator: (value) {
              final parsed = _parseTime(value ?? '');
              if (value == null || value.trim().isEmpty) {
                return 'Enter start time';
              }
              if (parsed == null) {
                return 'Enter a valid time (MM:SS or seconds)';
              }
              return null;
            },
            onChanged: (value) => setState(() {
              _startTimeStr = value;
              _startTime = _parseTime(value);
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'End Time (MM:SS or seconds, optional)',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.text,
            onChanged: (value) => setState(() {
              _endTimeStr = value;
              _endTime = _parseTime(value);
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a description'
                : null,
            onChanged: (value) => setState(() => _description = value),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (_formKey.currentState!.validate() &&
                        _startTime != null) {
                      setState(() => _isSubmitting = true);
                      try {
                        await widget.onAdd(
                          _startTime!,
                          _endTime,
                          _description.trim(),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
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
                : const Text('Add Step'),
          ),
        ],
      ),
    );
  }
}

class _EditRecipeForm extends StatefulWidget {
  final String initialName;
  final String? initialDescription;
  final Future<void> Function(String name, String? description) onSave;
  const _EditRecipeForm({
    required this.initialName,
    this.initialDescription,
    required this.onSave,
  });

  @override
  State<_EditRecipeForm> createState() => _EditRecipeFormState();
}

class _EditRecipeFormState extends State<_EditRecipeForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _description;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _description = widget.initialDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Recipe',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _name,
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
            initialValue: _description,
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
                        await widget.onSave(
                          _name.trim(),
                          _description?.trim().isEmpty ?? true
                              ? null
                              : _description?.trim(),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
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
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

String _formatStepTime(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}

class _EditStepForm extends StatefulWidget {
  final String initialStartTime;
  final String initialEndTime;
  final String initialDescription;
  final Future<void> Function(int start, int? end, String desc) onSave;
  const _EditStepForm({
    required this.initialStartTime,
    required this.initialEndTime,
    required this.initialDescription,
    required this.onSave,
  });

  @override
  State<_EditStepForm> createState() => _EditStepFormState();
}

class _EditStepFormState extends State<_EditStepForm> {
  final _formKey = GlobalKey<FormState>();
  late String _startTimeStr;
  late String _endTimeStr;
  int? _startTime;
  int? _endTime;
  late String _description;
  bool _isSubmitting = false;

  int? _parseTime(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length != 2) return null;
      final minutes = int.tryParse(parts[0]);
      final seconds = int.tryParse(parts[1]);
      if (minutes == null ||
          seconds == null ||
          minutes < 0 ||
          seconds < 0 ||
          seconds > 59)
        return null;
      return minutes * 60 + seconds;
    } else {
      final seconds = int.tryParse(trimmed);
      if (seconds == null || seconds < 0) return null;
      return seconds;
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimeStr = widget.initialStartTime;
    _endTimeStr = widget.initialEndTime;
    _startTime = _parseTime(_startTimeStr);
    _endTime = _parseTime(_endTimeStr);
    _description = widget.initialDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Step',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _startTimeStr,
            decoration: const InputDecoration(
              labelText: 'Start Time (MM:SS or seconds)',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.text,
            validator: (value) {
              final parsed = _parseTime(value ?? '');
              if (value == null || value.trim().isEmpty) {
                return 'Enter start time';
              }
              if (parsed == null) {
                return 'Enter a valid time (MM:SS or seconds)';
              }
              return null;
            },
            onChanged: (value) => setState(() {
              _startTimeStr = value;
              _startTime = _parseTime(value);
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _endTimeStr,
            decoration: const InputDecoration(
              labelText: 'End Time (MM:SS or seconds, optional)',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.text,
            onChanged: (value) => setState(() {
              _endTimeStr = value;
              _endTime = _parseTime(value);
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _description,
            decoration: const InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a description'
                : null,
            onChanged: (value) => setState(() => _description = value),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (_formKey.currentState!.validate() &&
                        _startTime != null) {
                      setState(() => _isSubmitting = true);
                      try {
                        await widget.onSave(
                          _startTime!,
                          _endTime,
                          _description.trim(),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
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
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
