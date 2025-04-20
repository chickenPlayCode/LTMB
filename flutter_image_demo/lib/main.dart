import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Demo',
      home: ImageDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageDemoScreen extends StatefulWidget {
  @override
  _ImageDemoScreenState createState() => _ImageDemoScreenState();
}

class _ImageDemoScreenState extends State<ImageDemoScreen> {
  File? _pickedImage;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hiển thị ảnh trong Flutter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cách 1: Hiển thị 3 ảnh từ assets, sử dụng Expanded để chia đều không gian
            Text("1. 3 ảnh từ assets:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Image.asset('assets/images/anh1.jpg'),
                ),
                Expanded(
                  child: Image.asset('assets/images/anh2.jpeg'),
                ),
                Expanded(
                  child: Image.asset('assets/images/anh3.jpeg'),
                ),
              ],
            ),

            SizedBox(height: 20),


          ],
        ),
      ),
    );
  }
}
