import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/analysis_result.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static const String _table = 'analyses';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, 'sdt_smishing_shield.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT NOT NULL,
            riskLevel TEXT NOT NULL,
            score INTEGER NOT NULL,
            indicators TEXT NOT NULL,
            explanation TEXT NOT NULL,
            recommendedAction TEXT NOT NULL,
            safeReply TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            source TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> saveAnalysis(AnalysisResult result) async {
    final db = await database;
    return db.insert(_table, result.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AnalysisResult>> fetchAnalyses() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map(AnalysisResult.fromMap).toList();
  }

  Future<void> deleteAnalysis(int id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_table);
  }
}
