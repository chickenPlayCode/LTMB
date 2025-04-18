import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_02/Note_Management/NoteApp/DatabaseHelper/DatabaseHelper.dart';
import "package:app_02/Note_Management/NoteApp/Model/NoteModel.dart";
import "package:app_02/Note_Management/NoteApp/UI/NoteDetailScreen.dart";
import "package:app_02/Note_Management/NoteApp/UI/NoteForm.dart";
import "package:app_02/Note_Management/NoteApp/widgets/NoteItem.dart";
import "package:app_02/Note_Management/NoteApp/UI/NoteListScreen.dart";

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/NoteModel.dart';

class NoteApiService {
  static const String _baseUrl = 'https://my-json-server.typicode.com/chickenPlayCode/noteflurter/notes';

  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<Note?> getNoteById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Note.fromMap(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> createNote(Note note) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toMap()),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateNote(Note note) async {
    if (note.id == null) return false;
    final response = await http.put(
      Uri.parse('$_baseUrl/${note.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toMap()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    return response.statusCode == 200;
  }

  Future<List<Note>> searchNotes(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Failed to search notes');
    }
  }

  Future<List<Note>> getNotesByPriority(int priority) async {
    final response = await http.get(Uri.parse('$_baseUrl?priority=$priority'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Failed to filter notes');
    }
  }


}
