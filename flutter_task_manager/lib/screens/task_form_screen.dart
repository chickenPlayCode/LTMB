import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  TaskFormScreen({this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  int priority = 1;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      title = widget.task!.title;
      description = widget.task!.description;
      priority = widget.task!.priority;
      dueDate = widget.task!.dueDate;
    } else {
      title = '';
      description = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? "Thêm công việc" : "Sửa công việc")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: "Tiêu đề"),
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: "Mô tả"),
                onSaved: (value) => description = value!,
              ),
              DropdownButtonFormField<int>(
                value: priority,
                decoration: InputDecoration(labelText: "Độ ưu tiên"),
                items: [
                  DropdownMenuItem(child: Text("Thấp"), value: 1),
                  DropdownMenuItem(child: Text("Trung bình"), value: 2),
                  DropdownMenuItem(child: Text("Cao"), value: 3),
                ],
                onChanged: (value) => setState(() => priority = value!),
              ),
              ListTile(
                title: Text(dueDate == null ? 'Chọn hạn' : dueDate.toString()),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => dueDate = picked);
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final task = TaskModel(
                      id: widget.task?.id ?? Uuid().v4(),
                      title: title,
                      description: description,
                      priority: priority,
                      dueDate: dueDate,
                      status: 'To do',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      completed: false,
                      createdBy: 'currentUserId', // bạn có thể lấy từ AuthProvider
                    );

                    if (widget.task == null) {
                      await taskProvider.addTask(task);
                    } else {
                      await taskProvider.updateTask(task);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.task == null ? 'Thêm' : 'Cập nhật'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
