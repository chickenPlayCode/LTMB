import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mô tả: ${task.description}'),
            SizedBox(height: 8),
            Text('Trạng thái: ${task.status}'),
            SizedBox(height: 8),
            Text('Độ ưu tiên: ${task.priority}'),
            SizedBox(height: 8),
            Text('Ngày hết hạn: ${task.dueDate?.toString() ?? 'Không có'}'),
            // Các trường khác như attachments, assignedTo...
          ],
        ),
      ),
    );
  }
}
