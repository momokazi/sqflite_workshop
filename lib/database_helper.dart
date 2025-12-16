import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'note.dart';

// Note: You must import your Note model
// import 'note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  // Constants
  static const String tableName = 'notes';
  static const String databaseName = 'notes_database.db';
  static const int databaseVersion = 1;

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize and open the database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL to create the database table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  // CREATE (Insert)
  Future<int> insertNote(Note note) async {
    final db = await database;
    // Uses the helper method for safety and simplicity
    return await db.insert(
      tableName,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ (Query all)
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // Convert the List<Map<String, dynamic>> to List<Note>
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // READ (Query one)
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> updateNote(Note note) async {
    final db = await database;
    // Ensure the note has an ID before updating
    return await db.update(
      tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
