import 'package:flutter/material.dart';
import 'group_gallery.dart';
import 'screens/friend_list_screen.dart';
import 'trash_service.dart';
import 'trash_item.dart';

class TrashScreen extends StatefulWidget {
  final String token;
  const TrashScreen({required this.token});

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late Future<List<TrashItem>> trashListFuture;

  @override
  void initState() {
    super.initState();
    trashListFuture = fetchTrashList(widget.token);
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
                trashListFuture = fetchTrashList(widget.token);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TrashItem>>(
        future: trashListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('에러 발생: ${snapshot.error}'));

          final trashList = snapshot.data!;
          return ListView.builder(
            itemCount: trashList.length,
            itemBuilder: (context, index) {
              final item = trashList[index];
              return Column(
                children: [
                  const Divider(),
                  ListTile(
                    title: Text('${item.whoUse}가 사용했습니다.'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('삭제일: ${item.deletedDate.toLocal()}'),
                        Text('사용일: ${item.usedDate.toLocal()}'),
                      ],
                    ),
                  ),
                ],
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
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => GroupGalleryPage(groupName: '콘갤러리'),
            ));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => FriendListScreen()));
          }
        },
      ),
    );
  }
}
