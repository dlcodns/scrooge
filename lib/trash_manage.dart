import 'package:flutter/material.dart';
import 'group_gallery.dart'; // 콘갤러리
import 'screens/friend_list_screen.dart'; // 친구목록

class TrashScreen extends StatelessWidget {
  final List<Map<String, String>> trashList = [
    {
      'date': '2025.01.26',
      'location': '박명우님의 친구방',
      'store': '스타벅스',
      'item': '카라멜 프라푸치노',
      'expiration': '',
    },
    {
      'date': '2025.01.05',
      'location': '이재훈님의 가족방',
      'store': '스타벅스',
      'item': '카라멜 프라푸치노',
      'expiration': '5일 후 삭제됩니다',
    },
    {
      'date': '2025.01.03',
      'location': '양종인이의 내방',
      'store': '스타벅스',
      'item': '카라멜 프라푸치노',
      'expiration': '5일 후 삭제됩니다',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('휴지통'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // 새로고침 로직이 있다면 여기에 작성
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: trashList.length,
        itemBuilder: (context, index) {
          final item = trashList[index];
          return Column(
            children: [
              Divider(),
              ListTile(
                title: Text('${item['location']}에서 사용했습니다.'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item['date']} 사용'),
                    SizedBox(height: 4),
                    Text(item['store'] ?? ''),
                    Text(item['item'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (item['expiration'] != null && item['expiration']!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item['expiration']!,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: '콘갤러리'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구 목록'),
        ],
        onTap: (index) {
          if (index == 0) {
            // 콘갤러리 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupGalleryPage(groupName: '콘갤러리'), // 파라미터 필요시 전달
              ),
            );
          } else if (index == 1) {
            // 친구목록 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FriendListScreen()),
            );
          }
        },
      ),
    );
  }
}
