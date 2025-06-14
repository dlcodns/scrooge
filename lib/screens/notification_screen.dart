import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  late int userId;
  late String token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndUserId();
  }

  Future<void> _loadTokenAndUserId() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwtToken') ?? '';
    userId = prefs.getInt('userId') ?? -1;

  print('📦 불러온 userId: $userId');
  print('📦 불러온 token: $token');

    if (token.isNotEmpty && userId != -1) {
      fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('http://172.30.1.18:8080/api/notifications/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print("🧪 요청하려는 receiverId: $userId");

    if (response.statusCode == 200) {
      final allNotifs = List<Map<String, dynamic>>.from(
        jsonDecode(response.body),
      );

      setState(() {
  _notifications = allNotifs;
});



      print("📡 요청 ID: $userId");
      print("📡 받은 응답: ${response.statusCode}");
      print("📡 응답 내용: ${response.body}");
    }

    print("🔔 알림 목록: $_notifications");
  }

  Future<void> handleFriendRequest(String action, int requestId) async {
    final url =
        action == 'accept' ? '/api/friends/accept' : '/api/friends/reject';

    final response = await http.post(
      Uri.parse('http://172.30.1.18:8080$url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _notifications.removeWhere((n) => n['targetId'] == requestId);
      });

      if (action == 'accept') {
        Navigator.pop(context, 'refresh');
      }
    }

    print("📨 수락 요청 보내는 ID: $requestId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          final type = notif['type'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif['message'] ?? ''),
              if (type == 'FRIEND_REQUEST' && notif['receiverId'] == userId) ...[
                Row(
                  children: [
                    TextButton(
                      onPressed: () => handleFriendRequest('accept', notif['targetId']),
                      child: const Text('수락하기'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => handleFriendRequest('reject', notif['targetId']),
                      child: const Text('거절하기'),
                    ),
                  ],
                ),
              ] else if (type == 'ROOM_INVITE') ...[
                TextButton(
                  onPressed: () {
                    // 방 초대 수락 or 이동 처리 예정
                  },
                  child: const Text('방 입장하기'),
                ),
              ],
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
