import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷용
import 'group_gallery.dart';
import 'screens/friend_list_screen.dart';
import 'trash_service.dart';
import 'trash_item.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({Key? key}) : super(key: key); // ✅ token 제거

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late Future<List<TrashItem>> trashListFuture;

  @override
  void initState() {
    super.initState();
    trashListFuture = fetchTrashList(); // ✅ token 없이 호출
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          '휴지통',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                trashListFuture = fetchTrashList(); // ✅ 다시 불러오기
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TrashItem>>(
        future: trashListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          final trashList = snapshot.data!;
          if (trashList.isEmpty) {
            return const Center(child: Text('휴지통이 비어 있습니다.'));
          }

          return ListView.separated(
            itemCount: trashList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = trashList[index];
              return ListTile(
                leading: const Icon(Icons.delete_forever),
                title: Text('${item.whoUse}가 사용한 기프트콘'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('삭제일: ${formatDate(item.deletedDate)}'),
                    Text('사용일: ${formatDate(item.usedDate)}'),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: '콘갤러리'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구 목록'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GroupGalleryPage(groupName: '콘갤러리')),
            );
          } else if (index == 1) {
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
