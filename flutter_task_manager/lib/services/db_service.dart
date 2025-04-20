import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'task_manager.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT,
        password TEXT,
        email TEXT,
        avatar TEXT,
        createdAt TEXT,
        lastActive TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        priority INTEGER,
        dueDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        assignedTo TEXT,
        createdBy TEXT,
        category TEXT,
        attachments TEXT,
        completed INTEGER
      )
    ''');
  }
}
