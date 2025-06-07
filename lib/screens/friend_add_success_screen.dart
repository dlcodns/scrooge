import 'package:flutter/material.dart';

import 'friend_list_screen.dart';

class FriendAddSuccessScreen extends StatefulWidget {
  final String friendName;
  const FriendAddSuccessScreen({super.key, required this.friendName});

  @override
  State<FriendAddSuccessScreen> createState() => _FriendAddSuccessScreenState();
}

class _FriendAddSuccessScreenState extends State<FriendAddSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(
        context,
        '/friend_list',
        arguments: widget.friendName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '친구 추가가 완료되었습니다!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
