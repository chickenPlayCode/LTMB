import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_02/Note_Management/NoteApp/DatabaseHelper/DatabaseHelper.dart';
import "package:app_02/Note_Management/NoteApp/Model/NoteModel.dart";
import "package:app_02/Note_Management/NoteApp/UI/NoteDetailScreen.dart";
import "package:app_02/Note_Management/NoteApp/UI/NoteForm.dart";
import "package:app_02/Note_Management/NoteApp/widgets/NoteItem.dart";
import "package:app_02/Note_Management/NoteApp/UI/NoteListScreen.dart";

import 'package:flutter/material.dart';

import 'dart:convert';

class Note {
  int? id;
  String title;
  String content;
  int priority;
  DateTime createdAt;
  DateTime modifiedAt;
  List<String>? tags;
  String? color;
  String? imagePath;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags?.join(','),
      'color': color,
      'imagePath': imagePath,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: map['tags']?.toString().split(','),
      color: map['color'],
      imagePath: map['imagePath'],
    );
  }
}





