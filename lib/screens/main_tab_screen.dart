import 'package:flutter/material.dart';
import 'friend_list_screen.dart';

class MainTabScreen extends StatefulWidget {
  final String token;
  final int userId;

  const MainTabScreen({required this.token, required this.userId, Key? key})
    : super(key: key);

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [
      const Center(child: Text("콘갤러리 (미구현)")), // 임시
      FriendListScreen(token: widget.token, userId: widget.userId),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: '콘갤러리'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구 목록'),
        ],
      ),
    );
  }
}
