import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/noteApp/db/NoteDatabaseHelper.dart';
import "package:app_02/noteApp/model/NoteModel.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


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
      } catch (e) {
        _selectedColor = Colors.white;
      }
    }
    if (imagePath != null && File(imagePath!).existsSync()) {
      _imageFile = File(imagePath!);
      print('Ảnh ban đầu tồn tại tại: $imagePath'); // Log để kiểm tra
    }
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tùy chọn màu ghi chú'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (Color newColor) {
              setState(() {
                _selectedColor = newColor;
                String hexColor = newColor.value.toRadixString(16).padLeft(8, '0').substring(2);
                color = hexColor;
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

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isPermanentlyDenied) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Quyền camera bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.'),
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

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (status.isPermanentlyDenied) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Quyền truy cập ảnh bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.'),
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

  Future<void> _takePhoto(BuildContext context) async {
    bool hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Cần cấp quyền truy cập camera để chụp ảnh')),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = '${directory.path}/$imageName';
        final File newImage = await File(photo.path).copy(imagePath);
        print('Đã sao chép ảnh từ ${photo.path} sang $imagePath'); // Log để kiểm tra
        if (await newImage.exists()) {
          print('File ảnh tồn tại sau khi sao chép'); // Log để kiểm tra
        } else {
          print('File ảnh KHÔNG tồn tại sau khi sao chép'); // Log để kiểm tra
        }
        setState(() {
          _imageFile = newImage;
          this.imagePath = imagePath;
        });
      } else {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Không có ảnh được chọn')),
        );
      }
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Lỗi khi chụp ảnh: $e')),
      );
      print('Lỗi khi chụp ảnh: $e'); // Log để debug
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = '${directory.path}/$imageName';
      final File newImage = await File(image.path).copy(imagePath);
      setState(() {
        _imageFile = newImage;
        this.imagePath = imagePath;
      });
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ảnh từ thư viện hoặc chụp ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(context);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh từ thư viện'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _takePhoto(context);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh từ camera'),
            ),
          ],
        ),
      ),
    );
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
                  decoration: InputDecoration(
                      labelText: 'Tiêu đề',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),  // Bo tròn góc với bán kính 12
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tiêu đề không được để trống';
                    }
                    return null;
                  },
                  onSaved: (value) => title = value!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: 16),
                TextFormField(
                  initialValue: content,
                  decoration: InputDecoration(
                      labelText: 'Nội dung',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),  // Bo tròn góc với bán kính 12
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nội dung không được để trống';
                    }
                    return null;
                  },
                  onSaved: (value) => content = value!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Thấp')),
                    DropdownMenuItem(value: 2, child: Text('Trung bình')),
                    DropdownMenuItem(value: 3, child: Text('Cao')),
                  ],
                  onChanged: (value) => setState(() => priority = value!),
                  decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text('Chọn màu: '),
                    GestureDetector(
                      onTap: () => _pickColor(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          border: Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showImagePickerDialog(context),
                  child: const Text('Thêm ảnh'),
                ),
                const SizedBox(height: 16),
                if (_imageFile != null)
                  Column(
                    children: [
                      FutureBuilder<bool>(
                        future: _imageFile!.exists(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasData && snapshot.data == true) {
                            return Image.file(
                              _imageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          }
                          return const Text('Ảnh không tồn tại');
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                            imagePath = null;
                          });
                        },
                        child: const Text('Xóa ảnh'),
                      ),
                    ],
                  ),

                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      try {
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
                        if (widget.note == null) {
                          await NoteDatabaseHelper.instance.insertNote(note);
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(content: Text('Ghi chú đã được thêm')),
                          );
                        } else {
                          await NoteDatabaseHelper.instance.updateNote(note);
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(content: Text('Ghi chú đã được sửa')),
                          );
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(content: Text('Lỗi khi lưu ghi chú: $e')),
                        );
                      }
                    }

                  },
                  child: Text('Lưu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
