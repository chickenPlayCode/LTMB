import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/noteApp/db/NoteDatabaseHelper.dart';
import "package:app_02/noteApp/model/NoteModel.dart";
import "package:app_02/noteApp/ui/NoteDetailScreen.dart";
import "package:app_02/noteApp/ui/NoteForm.dart";

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;

  const NoteItem({super.key, required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color priorityColor = note.priority == 1
        ? Colors.green
        : note.priority == 2
        ? Colors.orange
        : Colors.red;

    // Parse màu từ note.color
    Color backgroundColor;
    try {
      backgroundColor = note.color != null
          ? Color(int.parse(note.color!.replaceFirst('#', ''), radix: 16) + 0xFF000000)
          : Theme.of(context).cardTheme.color ?? Colors.white; // Màu mặc định nếu color là null
    } catch (e) {
      backgroundColor = Theme.of(context).cardTheme.color ?? Colors.white; // Nếu parse lỗi, dùng màu mặc định
    }

    return Card(
      margin: const EdgeInsets.all(8.0), // Margin giữa các items
      child: InkWell(
        onTap: () {
          // Điều hướng đến màn hình chi tiết ghi chú khi nhấn vào Card
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(note: note),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Container(
              color: backgroundColor,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.note, color: Colors.grey, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Nội dung và hình ảnh
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Hình ảnh
                  if (note.imagePath != null && File(note.imagePath!).existsSync())
                    Image.file(
                      File(note.imagePath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(width: 8),
                  // Nội dung
                  Expanded(
                    child: Text(
                      note.content.length > 20 ? '${note.content.substring(0, 20)}...' : note.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Thông tin ưu tiên và các nút
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Thông tin ưu tiên
                  Text(
                    note.priority == 1 ? "Thấp" : note.priority == 2 ? "Trung bình" : "Cao",
                    style: TextStyle(color: priorityColor),
                  ),
                  const Spacer(),
                  // Nút chỉnh sửa
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.green),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteFormScreen(note: note),
                        ),
                      );
                      onDelete();
                    },
                  ),
                  // Nút xóa
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn có chắc muốn xóa ghi chú này không?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await NoteDatabaseHelper.instance.deleteNote(note.id!);
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}