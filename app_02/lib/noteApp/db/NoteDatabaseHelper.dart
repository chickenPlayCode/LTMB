import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_02/noteApp/model/NoteModel.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  final String baseUrl = 'https://my-json-server.typicode.com/chickenPlayCode/noteflurter';

  NoteDatabaseHelper._init();

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách ghi chú');
    }
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/notes/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Note.fromMap(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Lỗi khi tải ghi chú');
    }
  }

  // Thêm ghi chú mới
  Future<int?> insertNote(Note note) async {
    final body = jsonEncode(note.toMap()..remove('id'));

    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id']; // Trả về ID ghi chú vừa tạo
    } else {
      print('Lỗi khi thêm ghi chú: ${response.body}');
      return null;
    }
  }

  // Cập nhật ghi chú
  Future<bool> updateNote(Note note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/${note.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toMap()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Lỗi khi cập nhật ghi chú: ${response.body}');
      return false;
    }
  }

  // Xóa ghi chú
  Future<bool> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/notes/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print('Lỗi khi xóa ghi chú: ${response.body}');
      return false;
    }
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final response = await http.get(Uri.parse('$baseUrl/notes?priority=$priority'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Lỗi khi tải ghi chú theo độ ưu tiên');
    }
  }

  // Tìm kiếm ghi chú theo tiêu đề hoặc nội dung
  Future<List<Note>> searchNotes(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final allNotes = data.map((json) => Note.fromMap(json)).toList();

      return allNotes.where((note) =>
      note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.content.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } else {
      throw Exception('Lỗi khi tìm kiếm ghi chú');
    }
  }
}
