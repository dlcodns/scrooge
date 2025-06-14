import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrooge/mypage.dart';
import '../group.dart';
import '../trash_manage.dart';

class Friend {
  final int id;
  final String name;
  final String preference;
  final String? second;
  final String? third;

  Friend({
    required this.id,
    required this.name,
    required this.preference,
    this.second,
    this.third,
  });
}

class FriendListScreen extends StatefulWidget {
  final String token;
  final int userId;

  const FriendListScreen({required this.token, required this.userId, Key? key})
    : super(key: key);

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _allFriends = [];

  @override
  void initState() {
    super.initState();
    fetchFriendList();
  }

  Future<void> fetchFriendList() async {
    final response = await http.get(
      Uri.parse('http://172.30.129.19:8080/api/friends'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _allFriends =
            json.map((item) {
              final prefs = item['preferences'] as List<dynamic>;
              return Friend(
                id: item['id'],
                name: item['nickname'],
                preference: prefs.isNotEmpty ? prefs[0] : '',
                second: prefs.length > 1 ? prefs[1] : null,
                third: prefs.length > 2 ? prefs[2] : null,
              );
            }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProfile(Friend friend) async {
    print("📍 프로필 진입: ${friend.name}, ID: ${friend.id}");
    final result = await Navigator.pushNamed(
      context,
      '/friend_profile',
      arguments: {'token': widget.token, 'userId': friend.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final matchingFriends =
        query.isEmpty
            ? []
            : _allFriends
                .where((friend) => friend.name.contains(query))
                .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                    MaterialPageRoute(
                      builder:
                          (_) => TrashScreen(
                            token: widget.token,
                            userId: widget.userId,
                          ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/notifications',
                    arguments: {'token': widget.token, 'userId': widget.userId},
                  );

                  if (result == 'refresh') {
                    fetchFriendList(); // ✅ 알림 수락 시 목록 갱신
                  }
                },
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MyPageScreen(
                            token: widget.token,
                            userId: widget.userId,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '친구 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
              ),
              if (matchingFriends.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Text(
                    '검색 결과',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    itemCount: matchingFriends.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final friend = matchingFriends[index];
                      return GestureDetector(
                        onTap: () => _navigateToProfile(friend),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.deepPurple.shade100,
                              child: const Icon(
                                Icons.person,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(friend.name),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('이름', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('선호', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _allFriends.length,
                  itemBuilder: (context, index) {
                    final friend = _allFriends[index];
                    return ListTile(
                      title: Text(friend.name),
                      trailing: Text(friend.preference),
                      onTap: () => _navigateToProfile(friend),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/friend_add',
                  arguments: {'token': widget.token, 'userId': widget.userId},
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              Group(token: widget.token, userId: widget.userId),
                    ),
                  );
                },
                child: Center(
                  child: Image.asset('assets/conGall_1.png', height: 20),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // 현재 페이지 유지
                },
                child: Center(
                  child: Image.asset('assets/friendList_1.png', height: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
