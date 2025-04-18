import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/Note_Management/NoteApp/Model/NoteModel.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                title: "Nội dung",
                content: note.content,
                icon: Icons.description,
              ),
              _buildCard(
                title: "Ưu tiên",
                content: _getPriorityText(note.priority),
                icon: Icons.flag,
              ),
              _buildCard(
                title: "Thời gian tạo",
                content: note.createdAt.toString(),
                icon: Icons.calendar_today,
              ),
              _buildCard(
                title: "Thời gian chỉnh sửa",
                content: note.modifiedAt.toString(),
                icon: Icons.update,
              ),
              if (note.tags != null && note.tags!.isNotEmpty)
                _buildCard(
                  title: "Nhãn",
                  content: note.tags!.join(', '),
                  icon: Icons.label,
                ),
              if (note.color != null)
                _buildCard(
                  title: "Màu sắc",
                  content: note.color!,
                  icon: Icons.color_lens,
                ),
              if (note.imagePath != null && note.imagePath!.isNotEmpty)
                _buildImageCard(note.imagePath!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    final isNetworkImage = imagePath.startsWith('http');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Ảnh đính kèm:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: isNetworkImage
                ? Image.network(
              imagePath,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Không thể tải ảnh',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            )
                : FutureBuilder<bool>(
              future: File(imagePath).exists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return Image.file(
                    File(imagePath),
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Không tìm thấy ảnh',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return "Thấp";
      case 2:
        return "Trung bình";
      case 3:
        return "Cao";
      default:
        return "Không xác định";
    }
  }
}
