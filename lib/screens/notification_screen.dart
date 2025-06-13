import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  final String token;
  final int userId;

  const NotificationScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('http://172.30.129.19:8080/api/notifications/${widget.userId}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    print("🧪 요청하려는 receiverId: ${widget.userId}");

    if (response.statusCode == 200) {
      final allNotifs = List<Map<String, dynamic>>.from(
        jsonDecode(response.body),
      );

      setState(() {
        _notifications =
            allNotifs
                .where(
                  (n) =>
                      // 내가 받은 알림이면서
                      n['receiverId'] == widget.userId &&
                      // FRIEND_REQUEST의 경우 sender가 내가 아닌 것만 (내가 나한테 보내는 알림 방지)
                      (n['type'] != 'FRIEND_REQUEST' ||
                          n['senderId'] != widget.userId),
                )
                .toList();
      });

      print("📡 요청 ID: ${widget.userId}");
      print("📡 받은 응답: ${response.statusCode}");
      print("📡 응답 내용: ${response.body}");
    }

    print("🔔 알림 목록: $_notifications");
  }

  Future<void> handleFriendRequest(String action, int requestId) async {
    final url =
        action == 'accept' ? '/api/friends/accept' : '/api/friends/reject';

    final response = await http.post(
      Uri.parse('http://172.30.129.19:8080$url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _notifications.removeWhere((n) => n['targetId'] == requestId);
      });

      if (action == 'accept') {
        // 👇 여기에 추가
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
              Text(notif['message']),
              if (type == 'FRIEND_REQUEST' &&
                  notif['receiverId'] == widget.userId) ...[
                Row(
                  children: [
                    TextButton(
                      onPressed:
                          () =>
                              handleFriendRequest('accept', notif['targetId']),
                      child: const Text('수락하기'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed:
                          () =>
                              handleFriendRequest('reject', notif['targetId']),
                      child: const Text('거절하기'),
                    ),
                  ],
                ),
              ] else if (type == 'ROOM_INVITE') ...[
                // 추후 방 초대 관련 처리
                TextButton(
                  onPressed: () {
                    // 방 초대 수락 or 이동
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
