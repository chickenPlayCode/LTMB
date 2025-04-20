import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Điều hướng giữa các màn hình',
      home: Screen1(), // Màn hình bắt đầu của ứng dụng
      debugShowCheckedModeBanner: false,
    );
  }
}

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Màn hình 1'),
        backgroundColor: Colors.teal, // Màu của app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thêm một hình ảnh trên màn hình
            Image.asset(
              'assets/images/anh1.jpg', // Đảm bảo bạn có ảnh trong thư mục assets
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Màu nền nút
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // Điều hướng tới màn hình thứ 2
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Screen2()),
                );
              },
              child: Text('Đi tới Màn hình 2', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Màn hình 2'),
        backgroundColor: Colors.orange, // Thay đổi màu AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thêm hình ảnh khác cho màn hình 2
            Image.asset(
              'assets/images/anh2.jpeg', // Đảm bảo bạn có ảnh trong thư mục assets
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Màu nền nút
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // Quay lại màn hình trước (Màn hình 1)
                Navigator.pop(context);
              },
              child: Text('Quay lại Màn hình 1', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
