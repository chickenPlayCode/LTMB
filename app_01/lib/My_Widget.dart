import 'package:flutter/material.dart';

class MyStatelessWidget extends StatelessWidget {
  final String title;

  const MyStatelessWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(title),
      ),
    );
  }
}

//================================================
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String title = "Hello, Nguyen Van A";
  int count = 0;

  void _updateTitle() {
    setState(() {
      title = "Hello, Lý Huy Hoàng ${count++}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center( // Thêm Center để căn giữa nội dung
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title),
            const SizedBox(height: 10), // Khoảng cách giữa Text và Button
            ElevatedButton(
              onPressed: _updateTitle,
              child: const Text('Update Title'),
            ),
          ],
        ),
      ),
    );
  }
}
