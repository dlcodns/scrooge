import 'package:flutter/material.dart';
import 'firstpage.dart'; // firstpage.dart import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigator Demo',
      home: const FirstPage(), // 첫 화면을 FirstPage로 지정
    );
  }
}
