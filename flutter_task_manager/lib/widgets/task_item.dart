import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../screens/task_detail_screen.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;

  TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text("Trạng thái: ${task.status}"),
      trailing: Icon(
        Icons.flag,
        color: task.priority == 3 ? Colors.red : (task.priority == 2 ? Colors.orange : Colors.green),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
        );
      },
    );
  }
}
