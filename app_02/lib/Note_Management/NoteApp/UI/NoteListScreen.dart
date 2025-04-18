import 'package:flutter/material.dart';
import 'package:app_02/Note_Management/NoteApp/Model/NoteModel.dart';
import 'package:app_02/Note_Management/NoteApp/UI/NoteForm.dart';
import 'package:app_02/Note_Management/NoteApp/widgets/NoteItem.dart';
import 'package:app_02/Note_Management/NoteApp/DatabaseHelper/DatabaseHelper.dart'; // Đây là NoteApiService

class NoteListScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;

  const NoteListScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late List<Note> notes;
  bool isLoading = false;
  bool isGridView = false;

  final NoteApiService _noteApiService = NoteApiService(); // ✅ Tạo instance

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future<void> refreshNotes() async {
    setState(() => isLoading = true);
    try {
      notes = await _noteApiService.getAllNotes(); // ✅ Gọi qua instance
    } catch (e) {
      notes = [];
      debugPrint('Error fetching notes: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Ghi Chú'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.onThemeChanged,
            tooltip: widget.isDarkMode
                ? 'Chuyển sang chế độ sáng'
                : 'Chuyển sang chế độ tối',
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
            tooltip: isGridView ? 'Chế độ danh sách' : 'Chế độ lưới',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') refreshNotes();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Làm mới'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(child: Text('Không có ghi chú nào'))
          : isGridView
          ? GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) => NoteItem(
          note: notes[index],
          onDelete: refreshNotes,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notes.length,
        itemBuilder: (context, index) => NoteItem(
          note: notes[index],
          onDelete: refreshNotes,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteFormScreen()),
          );
          refreshNotes();
        },
      ),
    );
  }
}
