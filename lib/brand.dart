import 'package:flutter/material.dart';
import 'time.dart';
import 'group.dart';
import 'brand_gallery.dart';
import 'screens/friend_list_screen.dart';
import 'trash_manage.dart';
import 'mypage.dart';

Widget _buildRoundedBox(
  BuildContext context,
  Widget destinationPage,
  int number,
) {
  String imagePath;
  Color boxColor = Colors.grey.shade300;

  // number 값에 따라 이미지 파일 경로를 다르게 설정
  if (number == 1) {
    imagePath = 'assets/group.png'; // 1번 박스 이미지
  } else if (number == 2) {
    imagePath = 'assets/time.png'; // 2번 박스 이미지
  } else {
    imagePath = 'assets/brand.png'; // 3번 박스 이미지
    boxColor = const Color(0xFF7081F1);
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destinationPage,
          transitionDuration: Duration.zero, // 전환 시간 0
          reverseTransitionDuration: Duration.zero, // 되돌아갈 때도 0
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
          width: 24, // 이미지 크기 조정
          height: 24,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

class Brand extends StatelessWidget {
  final String token; // ✅ 추가
  const Brand({required this.token, Key? key}) : super(key: key);
  

  final List<Map<String, dynamic>> brandInfo = const [
    {"name": "스타벅스", "image": "assets/starbucks.png"},
    {"name": "투썸플레이스", "image": "assets/twosome.png"},
    {"name": "편의점", "image": "assets/GS25.png"},
    {"name": "맥도날드", "image": "assets/mcdonalds.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final double itemSize = MediaQuery.of(context).size.width / 3;
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrashScreen(token: token)),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () {
                  // 👉 마이페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyPageScreen(token:token)),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildRoundedBox(context, Group(token:token), 1),
                const SizedBox(width: 8),
                _buildRoundedBox(context, Time(token:token), 2),
                const SizedBox(width: 8),
                _buildRoundedBox(context, Brand(token:token), 3),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 36,
                childAspectRatio: 0.7, // ✅ 텍스트 포함해서 높이 확보
                children:
                    brandInfo.map((brand) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BrandGalleryPage(
                                    brandName: brand["name"],
                                  ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: itemSize,
                              height: itemSize,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                brand["image"],
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              brand["name"],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2), // 위쪽 그림자
            ),
          ],
        ),
        height: 60,
        child: Row(
          children: [
            // 왼쪽 버튼
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
            // 오른쪽 버튼
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // ✅ 여기서 친구목록으로 이동!
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FriendListScreen(token:token)),
                  );
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
