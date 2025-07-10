import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../dao/profile_dao.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'brewy.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE profiles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          bio TEXT,
          profile_pic_path TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add new columns to recipes table
      await db.execute('ALTER TABLE recipes ADD COLUMN coffee_amount REAL');
      await db.execute('ALTER TABLE recipes ADD COLUMN water_amount REAL');
      await db.execute(
        'ALTER TABLE recipes ADD COLUMN use_ml INTEGER DEFAULT 0',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        coffee_amount REAL,
        water_amount REAL,
        use_ml INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE recipe_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipeId INTEGER NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        description TEXT NOT NULL,
        FOREIGN KEY(recipeId) REFERENCES recipes(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        bio TEXT,
        profile_pic_path TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<ProfileDao> getProfileDao() async {
    final db = await database;
    return ProfileDao(db);
  }
}
