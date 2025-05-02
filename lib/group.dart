import 'package:flutter/material.dart';
import 'time.dart';
import 'brand.dart';

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
    boxColor = const Color(0xFF7081F1);
  } else if (number == 2) {
    imagePath = 'assets/time.png'; // 2번 박스 이미지
  } else {
    imagePath = 'assets/brand.png'; // 3번 박스 이미지
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

class Group extends StatelessWidget {
  const Group({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 210, 101, 101),
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
                  // TODO: trash 버튼 기능 추가
                },
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () {
                  // TODO: heart 버튼 기능 추가
                },
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () {
                  // TODO: account 버튼 기능 추가
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
                _buildRoundedBox(context, Group(), 1),
                const SizedBox(width: 8),
                _buildRoundedBox(context, Time(), 2),
                const SizedBox(width: 8),
                _buildRoundedBox(context, Brand(), 3),
              ],
            ),
            // 여기에 다른 내용 추가 가능
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
