import 'package:flutter/material.dart';
import 'firstpage.dart'; // firstpage.dart import
import 'package:provider/provider.dart';
import 'gifticon_state.dart';

void main() {
  runApp(    
    ChangeNotifierProvider(
    create: (_) => GifticonState(),
    child: const MyApp(),
    ),
  );
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
