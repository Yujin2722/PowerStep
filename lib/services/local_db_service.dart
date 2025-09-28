// services/local_db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';

class LocalDBService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'powerstep.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
          CREATE TABLE users (
            uid TEXT PRIMARY KEY,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            age INTEGER,
            weight REAL,
            height REAL,
            steps INTEGER DEFAULT 0,
            calories REAL DEFAULT 0
          )
        ''');

        // Workouts table
        await db.execute('''
          CREATE TABLE workouts (
            workoutId TEXT PRIMARY KEY,
            type TEXT,
            duration INTEGER,
            calories REAL,
            timestamp TEXT
          )
        ''');

        // Daily Stats table
        await db.execute('''
          CREATE TABLE daily_stats (
            date TEXT PRIMARY KEY,
            calories REAL DEFAULT 0,
            distance REAL DEFAULT 0
          )
        ''');
      },
    );
  }

  // 🔹 Add User
  Future<void> addUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔹 Get Users
  Future<List<UserModel>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result
        .map((row) => UserModel.fromMap(row['uid'] as String, row))
        .toList();
  }

  // 🔹 Add Workout
  Future<void> addWorkout(WorkoutModel workout) async {
    final db = await database;
    await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔹 Delete Workout
  Future<void> deleteWorkout(String workoutId) async {
    final db = await database;
    await db.delete('workouts', where: 'workoutId = ?', whereArgs: [workoutId]);
  }

  // 🔹 Get Workouts
  Future<List<WorkoutModel>> getWorkouts() async {
    final db = await database;
    final result = await db.query('workouts');
    return result
        .map((row) => WorkoutModel.fromMap(row['workoutId'] as String, row))
        .toList();
  }

  // Save daily stats
  Future<void> upsertDailyStats(
    String date,
    double calories,
    double distance,
  ) async {
    final db = await database;
    await db.insert('daily_stats', {
      'date': date,
      'calories': calories,
      'distance': distance,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get stats for a specific date
  Future<Map<String, dynamic>?> getStatsForDate(String date) async {
    final db = await database;
    final result = await db.query(
      'daily_stats',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
