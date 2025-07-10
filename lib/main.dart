import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'presentation/pages/recipes_page.dart';
import 'presentation/pages/brew_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/dao/profile_dao.dart';
import 'data/datasources/database_helper.dart';

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
    return MultiProvider(
      providers: [
        // Database and DAOs
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper()),

        // Repositories and ViewModels
        FutureProvider<ProfileViewModel?>(
          create: (context) async {
            final dbHelper = context.read<DatabaseHelper>();
            final profileDao = await dbHelper.getProfileDao();
            final repository = ProfileRepositoryImpl(profileDao);
            final viewModel = ProfileViewModel(repository);
            // Load the profile immediately after creation
            await viewModel.loadProfile();
            return viewModel;
          },
          initialData: null,
        ),
      ],
      child: MaterialApp(
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
      ),
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
