import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'group.dart';
import 'screens/friend_list_screen.dart';
import 'trash_service.dart';
import 'trash_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late Future<List<TrashItem>> trashListFuture;

  @override
  void initState() {
    super.initState();
    _loadTrashList();
  }

  Future<void> _loadTrashList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';
    setState(() {
      trashListFuture = fetchTrashList();
    });
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
            onPressed: _loadTrashList,
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
                      '${item.whoUse}님이 친구방에서 사용했습니다.',
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
                  // ✅ 여기서 친구목록으로 이동!
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FriendListScreen()),
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
