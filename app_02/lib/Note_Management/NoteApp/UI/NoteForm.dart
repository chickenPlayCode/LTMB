import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_02/Note_Management/NoteApp/Model/NoteModel.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late String title;
  late String content;
  late int priority;
  List<String> tags = [];
  String? color;
  Color _selectedColor = Colors.white;
  String? imagePath;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  static const String _baseUrl = 'https://my-json-server.typicode.com/chickenPlayCode/noteflurter/notes';

  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    priority = widget.note?.priority ?? 1;
    tags = widget.note?.tags ?? [];
    color = widget.note?.color;
    imagePath = widget.note?.imagePath;

    if (color != null) {
      try {
        _selectedColor = Color(int.parse('0xff$color'));
      } catch (_) {
        _selectedColor = Colors.white;
      }
    }

    if (imagePath != null && File(imagePath!).existsSync()) {
      _imageFile = File(imagePath!);
    }
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn màu cho ghi chú'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (Color newColor) {
              setState(() {
                _selectedColor = newColor;
                color = newColor.value.toRadixString(16).padLeft(8, '0').substring(2);
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission(Permission permission, String message) async {
    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
    }
    if (status.isPermanentlyDenied) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Mở cài đặt',
            onPressed: openAppSettings,
          ),
        ),
      );
      return false;
    }
    return status.isGranted;
  }

  Future<void> _takePhoto() async {
    if (!await _requestPermission(Permission.camera, 'Quyền camera bị từ chối vĩnh viễn.')) return;

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      await _saveImageFile(photo);
    }
  }

  Future<void> _pickImage() async {
    if (!await _requestPermission(Permission.photos, 'Quyền ảnh bị từ chối vĩnh viễn.')) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _saveImageFile(image);
    } else {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Không có ảnh được chọn')),
      );
    }
  }

  Future<void> _saveImageFile(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newImagePath = '${directory.path}/$imageName';
      final File newImage = await File(image.path).copy(newImagePath);

      setState(() {
        _imageFile = newImage;
        imagePath = newImagePath;
      });
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Lỗi xử lý ảnh: $e')),
      );
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        priority: priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: tags,
        color: color,
        imagePath: imagePath,
      );

      final url = Uri.parse(
        widget.note == null
            ? _baseUrl
            : '$_baseUrl/${note.id}',
      );

      final response = await (widget.note == null
          ? http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.toMap()),
      )
          : http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.toMap()),
      ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(widget.note == null ? 'Đã thêm ghi chú thành công' : 'Đã cập nhật ghi chú thành công')),
        );
        Navigator.pop(context, true);
      } else {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Không thể lưu ghi chú.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm Ghi Chú' : 'Sửa Ghi Chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: title,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  validator: (value) => value == null || value.isEmpty ? 'Tiêu đề không được để trống' : null,
                  onSaved: (value) => title = value!,
                ),
                TextFormField(
                  initialValue: content,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                  validator: (value) => value == null || value.isEmpty ? 'Nội dung không được để trống' : null,
                  onSaved: (value) => content = value!,
                ),
                DropdownButtonFormField<int>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Thấp')),
                    DropdownMenuItem(value: 2, child: Text('Trung bình')),
                    DropdownMenuItem(value: 3, child: Text('Cao')),
                  ],
                  onChanged: (value) => setState(() => priority = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Chọn màu:'),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _pickColor(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Chụp ảnh'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Chọn ảnh'),
                    ),
                  ],
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 16),
                  Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  TextButton(
                    onPressed: () => setState(() {
                      _imageFile = null;
                      imagePath = null;
                    }),
                    child: const Text('Xóa ảnh'),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: Text(widget.note == null ? 'Lưu Ghi Chú' : 'Cập Nhật Ghi Chú'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
