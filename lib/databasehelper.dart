import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'diaryentry.dart';

class DatabaseHelper {
  static final _databaseName = "diary.db";
  static final _databaseVersion = 1;
  static final tableName = 'tbl_diary';

  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            notes TEXT NOT NULL,
            date TEXT NOT NULL,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertDiary(DiaryEntry entry) async {
    final db = await database;
    final data = entry.toMap();
    data.remove("id"); // Auto-increment
    return await db.insert(tableName, data);
  }

  // READ (Get all diary entries)
  Future<List<DiaryEntry>> getAllDiaries() async {
    final db = await database;
    final result = await db.query(
      tableName,
      orderBy: 'date DESC, id DESC',
    );
    return result.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  // READ (Get one by ID)
  Future<DiaryEntry?> getDiaryById(int id) async {
    final db = await database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return DiaryEntry.fromMap(result.first);
    }
    return null;
  }

  // UPDATE
  Future<int> updateDiary(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      tableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // DELETE (by ID)
  Future<int> deleteDiary(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE ALL
  Future<int> deleteAllDiaries() async {
    final db = await database;
    return await db.delete(tableName);
  }

  // SEARCH (by title or notes)
  Future<List<DiaryEntry>> searchDiaries(String keyword) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'title LIKE ? OR notes LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'date DESC',
    );
    return result.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  // CLOSE DATABASE
  Future<void> closeDb() async {
    final db = await database;
    await db.close();
  }
}
