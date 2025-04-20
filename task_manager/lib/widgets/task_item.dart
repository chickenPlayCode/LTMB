import 'package:flutter/material.dart';
import '../models/Task.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(bool) onComplete;
  final VoidCallback onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
  }) : super(key: key);

  // Lấy màu sắc dựa trên độ ưu tiên
  Color _getPriorityColor() {
    switch (task.priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
      default:
        return Colors.green;
    }
  }

  // Lấy biểu tượng dựa trên trạng thái
  IconData _getStatusIcon() {
    switch (task.status) {
      case 'In progress':
        return Icons.work;
      case 'Done':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      case 'To do':
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor().withOpacity(0.2),
          child: Icon(
            _getStatusIcon(),
            color: _getPriorityColor(),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.description.length > 50
                  ? '${task.description.substring(0, 50)}...'
                  : task.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Due: ${task.dueDate != null ? DateFormat.yMd().format(task.dueDate!) : 'Not set'}',
              style: TextStyle(
                color: task.dueDate != null && task.dueDate!.isBefore(DateTime.now())
                    ? Colors.red
                    : null,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (value) {
                if (value != null) {
                  onComplete(value);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}