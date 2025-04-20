import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/Task.dart';
import '../models/User.dart';
import '../widgets/task_item.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  List<Task> _tasks = [];
  String? _selectedStatus;
  String? _selectedCategory;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ModalRoute.of(context)!.settings.arguments as User?;
    if (user != null) {
      _currentUser = user;
    } else {
      _currentUser = User(
        id: '',
        username: 'Khách',
        password: '',
        email: '',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
    }
  }

  Future<void> _loadTasks({bool ignoreFilters = false}) async {
    final dbHelper = DatabaseHelper.instance;
    final tasks = await dbHelper.searchTasks(
      query: _searchController.text,
      status: ignoreFilters ? null : _selectedStatus,
      category: ignoreFilters ? null : _selectedCategory,
    );
    setState(() {
      _tasks = tasks;
    });
  }

  void _onSearchChanged() {
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _hienThiTrangThai(String status) {
    switch (status) {
      case 'To do':
        return 'Chưa Làm';
      case 'In progress':
        return 'Đang Làm';
      case 'Done':
        return 'Hoàn Thành';
      case 'Cancelled':
        return 'Hủy Bỏ';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Xin chào, ${_currentUser.fullname ?? _currentUser.username}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm công việc',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('Không tìm thấy công việc'))
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: _tasks[index],
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/task_detail',
                      arguments: {'task': _tasks[index], 'currentUser': _currentUser},
                    );
                    if (result == true) {
                      _loadTasks();
                    }
                  },
                  onComplete: (completed) async {
                    final dbHelper = DatabaseHelper.instance;
                    await dbHelper.updateTask(
                      _tasks[index].copyWith(completed: completed),
                    );
                    _loadTasks();
                  },
                  onDelete: () async {
                    final dbHelper = DatabaseHelper.instance;
                    await dbHelper.deleteTask(_tasks[index].id);
                    _loadTasks();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/task_form',
            arguments: {'task': null, 'currentUser': _currentUser},
          );
          if (result == true) {
            await _loadTasks(ignoreFilters: true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm công việc mới')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        String? tempCategory = _selectedCategory;
        return AlertDialog(
          title: const Text('Lọc Công Việc'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tempStatus,
                hint: const Text('Chọn Trạng Thái'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tất Cả')),
                  DropdownMenuItem(value: 'To do', child: Text('Chưa Làm')),
                  DropdownMenuItem(value: 'In progress', child: Text('Đang Làm')),
                  DropdownMenuItem(value: 'Done', child: Text('Hoàn Thành')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Hủy Bỏ')),
                ],
                onChanged: (value) {
                  tempStatus = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Danh Mục',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  tempCategory = value.isEmpty ? null : value;
                },
                controller: TextEditingController(text: tempCategory),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = tempStatus;
                  _selectedCategory = tempCategory;
                });
                _loadTasks();
                Navigator.pop(context);
              },
              child: const Text('Áp Dụng'),
            ),
          ],
        );
      },
    );
  }
}