import 'dart:io';
import 'package:flutter/material.dart';
import "package:app_02/noteApp/model/NoteModel.dart";


class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nội dung: ${note.content}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text('Ưu tiên: ${note.priority == 1 ? "Thấp" : note.priority == 2 ? "Trung bình" : "Cao"}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text('Thời gian tạo: ${note.createdAt}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text('Thời gian sửa: ${note.modifiedAt}', style: Theme.of(context).textTheme.bodyLarge),
              if (note.tags != null && note.tags!.isNotEmpty)
                Text('Nhãn: ${note.tags!.join(', ')}', style: Theme.of(context).textTheme.bodyLarge),
              if (note.color != null)
                Text('Màu: ${note.color}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              if (note.imagePath != null && note.imagePath!.isNotEmpty)
                FutureBuilder<bool>(
                  future: Future(() async {
                    try {
                      final file = File(note.imagePath!);
                      return await file.exists();
                    } catch (e) {
                      return false; // Trả về false nếu có lỗi
                    }
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data == true) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ảnh đính kèm:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Image.file(
                            File(note.imagePath!),
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Không thể tải ảnh');
                            },
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink(); // Không hiển thị nếu file không tồn tại
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}