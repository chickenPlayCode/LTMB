import 'package:flutter/material.dart';
import 'My_Widget.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyStatefulWidget(),
    );
  }
}

/*
A. Giớii thiệu widget:
Widgets là các thành phần cơ bản để xây dựng
giao diện người dùng trong Flutter. Mọi thứ
trong Flutter đều là một widget, từ các nút bấm,
 văn bản đến các bố cục phức tạp hơn.
  Widgets có thể lồng nhau để tạo ra
 giao diện người dùng phong phú và đa dạng.

B. phân lại widget
 Platform-specific widgets
Material Widgets: Thiết kế theo Material Design của Google
import 'package:flutter/material.dart';

Cupertino Widgets: Thiết kế theo Human Interface Guidelines của Apple
import 'package:flutter/cupertino.dart';

+ Layout widgets: Container, Center, Row, Column, Stack ...
+ State maintenance widgets: StatelessWidget / StatefulWidget
+ Platform-independent/basic widgets: Text, Icon, Image, ElevatedButton, ListView ...

C. StatelessWidget / StatefulWidget
+ StatelessWidget: StatelessWidget là các widget tĩnh không thể thay đổi nội dung hiển thị sau khi được render. Đây là các widget đơn giản với cấu trúc rõ ràng, dễ sử dụng. Một StatelessWidget yêu cầu một hàm build(BuildContext context) để render dữ liệu lên màn hình.

+ StatefulWidget: StatefulWidget là các widget động có thể thay đổi nội dung hiển thị bằng cách thay đổi trạng thái của chính nó. StatefulWidget cần một hàm createState() để cung cấp trạng thái (State) cho nó.

 */


