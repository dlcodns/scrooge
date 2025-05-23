import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          '알림',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 친구 요청 알림
            const Text('송영은님에게 친구 신청이 왔습니다'),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {}, // 수락 로직
                  child: const Text('수락하기'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {}, // 거절 로직
                  child: const Text('거절하기'),
                ),
              ],
            ),
            const Divider(),

            // 초대 알림
            const SizedBox(height: 8),
            const Text('박형우님이 밤이틀에 초대했습니다.'),
            const Divider(),

            // 기프티콘 만료 알림
            const SizedBox(height: 8),
            const Text('스타벅스 아메리카노 tall 기프티콘이 곧 만료됩니다'),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '만료일 : 2025.02.14',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
