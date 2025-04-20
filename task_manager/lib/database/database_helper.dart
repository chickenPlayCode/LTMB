import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/User.dart';
import '../models/Task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar TEXT,
        createdAt TEXT NOT NULL,
        lastActive TEXT NOT NULL,
        birthDate TEXT,
        phoneNumber TEXT,
        fullname TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        priority INTEGER NOT NULL,
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        assignedTo TEXT,
        createdBy TEXT NOT NULL,
        category TEXT,
        attachments TEXT,
        completed INTEGER NOT NULL,
        FOREIGN KEY (createdBy) REFERENCES users(id)
      )
    ''');
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> searchTasks({String? query, String? status, String? category}) async {
    final db = await database;
    String whereString = '';
    List<dynamic> whereArguments = [];

    if (query != null && query.isNotEmpty) {
      whereString += 'title LIKE ? OR description LIKE ?';
      whereArguments.add('%$query%');
      whereArguments.add('%$query%');
    }

    if (status != null && status.isNotEmpty) {
      whereString += whereString.isEmpty ? 'status = ?' : ' AND status = ?';
      whereArguments.add(status);
    }

    if (category != null && category.isNotEmpty) {
      whereString += whereString.isEmpty ? 'category = ?' : ' AND category = ?';
      whereArguments.add(category);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArguments.isEmpty ? null : whereArguments,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<void> createUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> createTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'task_manager.db');
    await deleteDatabase(path);
    print('Database deleted');
  }

  Future<void> debugUsers() async {
    final users = await getAllUsers();
    print('Users table: ${users.map((u) => {'id': u.id, 'username': u.username, 'fullname': u.fullname}).toList()}');
  }

  Future<void> debugTasks() async {
    final tasks = await getAllTasks();
    print('Tasks table: ${tasks.map((t) => {'id': t.id, 'title': t.title, 'createdBy': t.createdBy}).toList()}');
  }
}