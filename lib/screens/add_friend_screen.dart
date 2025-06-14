import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrooge/screens/friend_add_success_screen.dart';

class FriendAddScreen extends StatefulWidget {
  final String token;
  final int myUserId;
  const FriendAddScreen({
    super.key,
    required this.token,
    required this.myUserId,
  });

  @override
  State<FriendAddScreen> createState() => _FriendAddScreenState();
}

class _FriendAddScreenState extends State<FriendAddScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> sendFriendRequest() async {
    final receiverId = _controller.text.trim();
    if (receiverId.isEmpty) return;

    final baseUrl = 'http://172.30.129.19:8080';

    // 1. 친구 요청 보내기
    final response = await http.post(
      Uri.parse('$baseUrl/api/friends/request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({'receiverUserId': receiverId}),
    );

    if (response.statusCode == 200) {
      try {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => FriendAddSuccessScreen(
                  friendName: receiverId,
                  token: widget.token,
                  userId: widget.myUserId,
                ),
          ),
        );
      } catch (e) {
        print('JSON 파싱 실패: $e');
        print('원본 응답: ${response.body}');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('친구 요청에 실패했습니다')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          '친구 추가',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '추가하고 싶은 친구의 ID를 입력하세요',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: sendFriendRequest,
              child: const Icon(
                Icons.arrow_forward,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
