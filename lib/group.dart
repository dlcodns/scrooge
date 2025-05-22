import 'package:flutter/material.dart';
import 'group_gallery.dart'; // 새 페이지 import 필요
import 'time.dart';
import 'brand.dart';

class Group extends StatelessWidget {
  const Group({super.key});

  final List<Map<String, dynamic>> groupInfo = const [
    {"name": "가족방", "icon": Icons.family_restroom, "emoji": "😊"},
    {"name": "친구방", "icon": Icons.people, "emoji": "😎"},
    {"name": "연인방", "icon": Icons.favorite, "emoji": "🥰"},
    {"name": "회사방", "icon": Icons.business, "emoji": "💼"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Image.asset('assets/trash.png'),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 오른쪽 상단 필터 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildRoundedBox(context, const Group(), 1),
                const SizedBox(width: 8),
                _buildRoundedBox(context, const Time(), 2),
                const SizedBox(width: 8),
                _buildRoundedBox(context, const Brand(), 3),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ 그룹 목록 3열
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: groupInfo.map((group) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupGalleryPage(groupName: group["name"]),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(group["emoji"], style: const TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(height: 6),
                        Text(group["name"], style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),

      // 하단바 유지
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // TODO: conGall 동작
                },
                child: Center(
                  child: Image.asset('assets/conGall.png', height: 20),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // TODO: friendList 동작
                },
                child: Center(
                  child: Image.asset('assets/friendList.png', height: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 기존 _buildRoundedBox 함수는 그대로 유지
Widget _buildRoundedBox(
  BuildContext context,
  Widget destinationPage,
  int number,
) {
  String imagePath;
  Color boxColor = Colors.grey.shade300;

  if (number == 1) {
    imagePath = 'assets/group.png';
    boxColor = const Color(0xFF7081F1);
  } else if (number == 2) {
    imagePath = 'assets/time.png';
  } else {
    imagePath = 'assets/brand.png';
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destinationPage,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    },
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}
