import 'package:flutter/material.dart';
import 'package:scrooge/mypage.dart';
class Friend {
  final String name;
  final String preference;
  final String? second;
  final String? third;
  bool isFavorite;

  Friend({
    required this.name,
    required this.preference,
    this.second,
    this.third,
    this.isFavorite = false,
  });
}

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _allFriends = [];

  @override
  void initState() {
    super.initState();
    _allFriends = [
      Friend(name: '박형우', preference: '커피', second: '치킨', third: '떡볶이'),
      Friend(name: '홍길동', preference: '커피', second: '쿠키', third: '케이크'),
      Friend(name: '송영은', preference: '올리브영', second: '아이스크림', third: '마카롱'),
      Friend(name: '박흠흠', preference: '초콜릿'),
      Friend(name: '박꾀티', preference: '딸기라떼'),
    ];
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProfile(Friend friend) async {
    final result =
        await Navigator.pushNamed(
              context,
              '/friend_profile',
              arguments: {
                'name': friend.name,
                'first': friend.preference,
                'second': friend.second ?? '',
                'third': friend.third ?? '',
                'isFavorite': friend.isFavorite,
              },
            )
            as Map<String, dynamic>?;

    if (result != null && result['name'] == friend.name) {
      final isNowFavorite = result['isFavorite'] ?? false;

      if (!isNowFavorite && friend.isFavorite) {
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('즐겨찾기 삭제'),
                content: Text('${friend.name}님을 즐겨찾기에서 해제할까요?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
        if (confirm != true) return;
      }

      setState(() {
        friend.isFavorite = isNowFavorite;
      });
    }
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
    final favoriteFriends = _allFriends.where((f) => f.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알뜰티콘',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: const Text('❤️', style: TextStyle(fontSize: 20)),
          ),

          IconButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MyPageScreen()),
      );
    },
    icon: const Icon(Icons.person),
    color: Colors.black,
  ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // ← 이게 뒤로가기 없애주는 거야!
      ),

      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/friend_add'),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          if (favoriteFriends.isNotEmpty) ...[
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                '즐겨찾기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: favoriteFriends.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final friend = favoriteFriends[index];
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
    );
  }
}
