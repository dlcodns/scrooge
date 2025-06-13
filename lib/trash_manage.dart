import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'group_gallery.dart';
import 'screens/friend_list_screen.dart';
import 'trash_service.dart';
import 'trash_item.dart';

class TrashScreen extends StatefulWidget {
  final String token;
  final int userId;

  const TrashScreen({required this.token, required this.userId, Key? key})
    : super(key: key);

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

  String formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date.toLocal());
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
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
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
              final daysUntilDelete =
                  item.deletedDate.difference(DateTime.now()).inDays;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.whoUse}님이 친구방에서 사용했습니다.', // 또는 item.location 사용 가능
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _buildDateBox(item.usedDate),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text(item.gifticonName)],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),
                    if (daysUntilDelete >= 0)
                      Text(
                        '${daysUntilDelete}일 후 삭제됩니다',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
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
              MaterialPageRoute(
                builder: (_) => GroupGalleryPage(groupName: '콘갤러리'),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => FriendListScreen(
                      token: widget.token,
                      userId: widget.userId,
                    ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDateBox(DateTime date) {
    final dateStr = DateFormat('yyyy.MM.dd').format(date);
    final parts = dateStr.split('.');
    final year = parts[0];
    final monthDay = '${parts[1]}.${parts[2]}';

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$monthDay',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            '사용',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
