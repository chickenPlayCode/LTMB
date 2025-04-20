import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/db_service.dart';
import 'package:sqflite/sqflite.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  Future<void> loadTasks() async {
    final db = await DBService.database;
    final maps = await db.query('tasks');

    _tasks = maps.map((map) => TaskModel.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    final db = await DBService.database;
    await db.insert('tasks', task.toMap());
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await DBService.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    _tasks[index] = task;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final db = await DBService.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
