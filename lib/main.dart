import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() {
  runApp(const BrewyApp());
}

// --- Recipe Model ---
class RecipeStep {
  final int startSeconds;
  final int endSeconds;
  final String description;

  RecipeStep({
    required this.startSeconds,
    required this.endSeconds,
    required this.description,
  });

  bool isInRange(int seconds) =>
      seconds >= startSeconds && seconds <= endSeconds;
}

class Recipe {
  final String name;
  final List<RecipeStep> steps;

  Recipe({required this.name, required this.steps});
}

final v60Recipe = Recipe(
  name: 'V60 1 Cup',
  steps: [
    RecipeStep(
      startSeconds: 0,
      endSeconds: 15,
      description: 'Pour to 50g before allowing to bloom.',
    ),
    RecipeStep(
      startSeconds: 15,
      endSeconds: 45,
      description: 'Bloom: Let coffee bloom. Gentle swirl at 0:15.',
    ),
    RecipeStep(
      startSeconds: 45,
      endSeconds: 60,
      description: 'Pour to ~100g total.',
    ),
    RecipeStep(startSeconds: 60, endSeconds: 70, description: 'Pause.'),
    RecipeStep(
      startSeconds: 70,
      endSeconds: 80,
      description: 'Pour to ~150g total.',
    ),
    RecipeStep(startSeconds: 80, endSeconds: 90, description: 'Pause.'),
    RecipeStep(
      startSeconds: 90,
      endSeconds: 100,
      description: 'Pour to ~200g total.',
    ),
    RecipeStep(startSeconds: 100, endSeconds: 110, description: 'Pause.'),
    RecipeStep(
      startSeconds: 110,
      endSeconds: 120,
      description: 'Pour to ~250g total.',
    ),
    RecipeStep(
      startSeconds: 120,
      endSeconds: 180,
      description: 'Gentle swirl, wait for drawdown to complete.',
    ),
  ],
);

class BrewyApp extends StatelessWidget {
  const BrewyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brewy',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF18181B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const BrewyNavScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BrewyNavScaffold extends StatefulWidget {
  const BrewyNavScaffold({super.key});

  @override
  State<BrewyNavScaffold> createState() => _BrewyNavScaffoldState();
}

class _BrewyNavScaffoldState extends State<BrewyNavScaffold> {
  int _selectedIndex = 1; // Default to Brew page

  final List<Widget> _pages = [
    const RecipesPage(),
    const BrewPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF18181B),
        indicatorColor: Colors.white10,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.coffee_outlined),
            selectedIcon: Icon(Icons.coffee),
            label: 'Brew',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- Recipes Page ---
class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const Center(
        child: Text(
          'Your recipes will appear here.',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      ),
    );
  }
}

// --- Brew Page (moved timer/stepper here) ---
class BrewPage extends StatefulWidget {
  const BrewPage({super.key});

  @override
  State<BrewPage> createState() => _BrewPageState();
}

class _BrewPageState extends State<BrewPage> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  Recipe get recipe => v60Recipe;

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  RecipeStep? getCurrentStep() {
    RecipeStep? current;
    for (final step in recipe.steps) {
      if (step.isInRange(_seconds)) {
        if (current == null || step.startSeconds >= current.startSeconds) {
          current = step;
        }
      }
    }
    if (current == null && _seconds > recipe.steps.last.endSeconds)
      return recipe.steps.last;
    return current ?? recipe.steps.first;
  }

  RecipeStep? getNextStep() {
    final now = _seconds;
    final futureSteps = recipe.steps
        .where((s) => s.startSeconds > now)
        .toList();
    if (futureSteps.isNotEmpty) {
      futureSteps.sort((a, b) => a.startSeconds.compareTo(b.startSeconds));
      return futureSteps.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.white;
    final secondary = const Color(0xFF27272A);
    final currentStep = getCurrentStep();
    final nextStep = getNextStep();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Brewy',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: accent,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_seconds == 0 && !_isRunning) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
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
              onTap: _toggleTimer,
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
            if (nextStep != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Column(
                  children: [
                    Text(
                      'Up next at ${_formatTime(nextStep.startSeconds)}',
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
                  onPressed: _toggleTimer,
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
  }
}

// --- Profile Page ---
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Your profile and settings will appear here.',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      ),
    );
  }
}
