import 'package:flutter/material.dart';
import 'package:scrooge/mypage.dart';
import 'group_gallery.dart';
import 'time.dart';
import 'brand.dart';
import 'group_create.dart';
import 'screens/friend_list_screen.dart';
import 'trash_manage.dart';
import 'screens/notification_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class Group extends StatefulWidget {
  final bool showToastMessage;
  const Group({super.key, this.showToastMessage = false});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  List<Map<String, dynamic>> groupInfo = []; // 서버에서 받아올 그룹 목록

  final List<Color> colorList = [ // 랜덤 색상 목록
    Colors.blue.shade100,
    Colors.pink.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.red.shade100,
  ];

  Future<void> fetchGroupRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final response = await http.get(
      Uri.parse('http://192.168.26.252:8080/api/group/my-rooms'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        groupInfo = data.map((group) {
          final color = colorList[group['id'] % colorList.length];
          return {
            'id': group['id'],
            'name': group['roomName'],
            'color': color,
          };
        }).toList();
      });
    } else {
      print('❌ 그룹 불러오기 실패: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGroupRooms();
    if (widget.showToastMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('방이 생성되었습니다.')),
        );
      });
    }
  }

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
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrashScreen()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPageScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                const SizedBox(height: 16),
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
                              builder: (_) => GroupGalleryPage(groupName: group["name"]), // 필요시 groupId도 넘겨줘
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: group['color'],
                              child: Text(
                                group["name"][0], // 첫 글자만 표시
                                style: const TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              group["name"],
                              style: const TextStyle(fontSize: 14),
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
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => GroupCreateStep1(),
                  ),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF7081F1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FriendListScreen(),
                    ),
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
