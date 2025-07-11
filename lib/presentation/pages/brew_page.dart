import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';
import '../viewmodels/brew_viewmodel.dart';
import 'dart:async';
import '../../domain/entities/recipe_step.dart';

class BrewPage extends StatefulWidget {
  const BrewPage({super.key});

  @override
  State<BrewPage> createState() => _BrewPageState();
}

class _BrewPageState extends State<BrewPage> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
  }

  void _stopTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildNoRecipesView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No Recipes Found',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You need to create a recipe before you can start brewing.',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Tap "Recipes" at the bottom to create your first recipe.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white54,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BrewViewModel>(
      builder: (context, viewModel, child) {
        final recipe = viewModel.selectedRecipe;
        final steps = viewModel.steps;
        final accent = Colors.white;
        final secondary = const Color(0xFF27272A);

        // Step logic (same as before, but using steps from viewModel)
        RecipeStep? getCurrentStep() {
          RecipeStep? current;
          for (final step in steps) {
            if (_seconds >= step.startTime &&
                (_seconds <= (step.endTime ?? 99999))) {
              if (current == null || step.startTime >= current.startTime) {
                current = step;
              }
            }
          }
          if (current == null &&
              steps.isNotEmpty &&
              _seconds > (steps.last.endTime ?? 99999))
            return steps.last;
          return current ?? (steps.isNotEmpty ? steps.first : null);
        }

        RecipeStep? getNextStep() {
          final now = _seconds;
          final futureSteps = steps.where((s) => s.startTime > now).toList();
          if (futureSteps.isNotEmpty) {
            futureSteps.sort((a, b) => a.startTime.compareTo(b.startTime));
            return futureSteps.first;
          }
          return null;
        }

        final currentStep = getCurrentStep();
        final nextStep = getNextStep();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: recipe == null
                ? Text(
                    'Brewy',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: accent,
                      letterSpacing: 1.2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<Recipe>(
                        initialValue: recipe,
                        onSelected: (selected) async {
                          await viewModel.selectRecipe(selected);
                          setState(() {
                            _seconds = 0;
                            _isRunning = false;
                          });
                        },
                        itemBuilder: (context) => viewModel.recipes
                            .map(
                              (r) => PopupMenuItem(
                                value: r,
                                child: Text(r.name, style: GoogleFonts.inter()),
                              ),
                            )
                            .toList(),
                        child: Row(
                          children: [
                            Text(
                              recipe.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: accent,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            centerTitle: true,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : recipe == null
              ? _buildNoRecipesView(context)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_seconds == 0 && !_isRunning) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  recipe.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (recipe.description != null &&
                                    recipe.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      recipe.description!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  'Ready to start?',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        if (currentStep != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              currentStep.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                      GestureDetector(
                        onTap: _isRunning ? _stopTimer : _startTimer,
                        child: Container(
                          width: 340,
                          padding: const EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: secondary,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            _formatTime(_seconds),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: accent,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      if (nextStep != null && (_isRunning || _seconds > 0)) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 24.0,
                            bottom: 24.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Up next at ${_formatTime(nextStep.startTime)}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: accent.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nextStep.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: accent.withOpacity(0.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 48),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isRunning ? _stopTimer : _startTimer,
                            icon: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              color: secondary,
                            ),
                            label: Text(
                              _isRunning ? 'Pause' : 'Start',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: secondary,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: secondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton.icon(
                            onPressed: _resetTimer,
                            icon: Icon(Icons.refresh, color: accent),
                            label: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: accent,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondary,
                              foregroundColor: accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _isRunning ? 'Brewing in progress...' : 'Ready to brew',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
