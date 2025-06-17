import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ImageDetailPage.dart';
import 'gifticon_select_page.dart';

class GroupGalleryPage extends StatefulWidget {
  final int groupId;

  const GroupGalleryPage({super.key, required this.groupId});

  @override
  State<GroupGalleryPage> createState() => _GroupGalleryPageState();
}

const String baseUrl = 'http://172.30.1.54:8080';

class GroupGifticon {
  final String gifticonId;
  final String title;
  final String imageUrl;
  final DateTime expiredAt;

  GroupGifticon({
    required this.gifticonId,
    required this.title,
    required this.imageUrl,
    required this.expiredAt,
  });

  factory GroupGifticon.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['imageUrl'];
    if (rawImageUrl == null) {
      throw Exception("imageUrl is missing in response: $json");
    }

    final fullImageUrl = rawImageUrl.startsWith('http')
        ? rawImageUrl
        : '$baseUrl$rawImageUrl';

    return GroupGifticon(
      gifticonId: json['gifticonNumber'] ?? '', 
      title: json['brand'] ?? '제목 없음',
      imageUrl: fullImageUrl,
      expiredAt: DateTime.parse(json['dueDate']),
    );
  }
}


class _GroupGalleryPageState extends State<GroupGalleryPage> {
  bool isGridView = true;
  bool showDrawer = false;
  String? groupName;

  List<GroupGifticon> _gifticons = [];
  Map<String, List<GroupGifticon>> _groupedGifticons = {};

  List<String> members = [];

  Future<void> _loadGroupMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';

    final url = Uri.parse('$baseUrl/api/group/${widget.groupId}/members');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      setState(() {
        members = jsonList.map((e) => e['nickname'].toString()).toList();
      });
    } else {
      print('멤버 로드 실패: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGroupName();
    _fetchGifticons();
    _loadGroupMembers();
  }

  Future<void> _loadGroupName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';

    final url = Uri.parse('http://172.30.1.54:8080/api/group/${widget.groupId}/name');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      setState(() {
        groupName = json.decode(response.body)['groupName'];
      });
    } else {
      print('그룹 이름 로드 실패: \${response.body}');
    }
  }

  void _groupGifticonsByDate(List<GroupGifticon> gifticons) {
    Map<String, List<GroupGifticon>> grouped = {};

    for (var gifticon in gifticons) {
      final date = gifticon.expiredAt;
      final key = "${date.year}년 ${date.month}월 만료";

      grouped.putIfAbsent(key, () => []).add(gifticon);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aParts = RegExp(r'(\d{4})년 (\d{1,2})월').firstMatch(a)!;
        final bParts = RegExp(r'(\d{4})년 (\d{1,2})월').firstMatch(b)!;

        final aDate = DateTime(int.parse(aParts[1]!), int.parse(aParts[2]!));
        final bDate = DateTime(int.parse(bParts[1]!), int.parse(bParts[2]!));

        return aDate.compareTo(bDate);
      });

    setState(() {
      _groupedGifticons = {
        for (var key in sortedKeys) key: grouped[key]!
      };
    });
  }

  


  Future<void> _fetchGifticons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';

    final url = Uri.parse('http://172.30.1.54:8080/api/group/${widget.groupId}/group_gifticons');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final gifticons = jsonList.map((json) => GroupGifticon.fromJson(json)).toList();

      setState(() {
        _gifticons = gifticons;
      });

      _groupGifticonsByDate(gifticons); // ✅ 꼭 호출!
    } else {
      print('❌ Error loading gifticons: ${response.body}');
    }
  }

  String formatDateKey(String rawKey) {
  try {
    final date = DateTime.parse(rawKey.replaceAll(" 만료", ""));
    return "${date.month}월 ${date.day}일 만료";
  } catch (_) {
    return rawKey;
  }
}


  void _openGifticonSelectPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GifticonSelectPage(groupId: widget.groupId),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기프티콘이 등록되었습니다.')),
      );
      _fetchGifticons();
    }
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
        title: Text(
          groupName ?? " ",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              setState(() {
                showDrawer = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildViewToggleButtons(),
              const SizedBox(height: 16),
              ..._groupedGifticons.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatDateKey(entry.key), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),
                    isGridView
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.value.map((item) => _buildGifticonGridItem(item)).toList(),
                          )
                        : Column(
                            children: entry.value.map((item) => _buildGifticonListItem(item)).toList(),
                          ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ],
          ),
          if (showDrawer)
            Positioned.fill(
              top: kToolbarHeight,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => showDrawer = false),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("친구 목록", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                          const SizedBox(height: 16),
                          ...members.map((name) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(name, style: const TextStyle(fontSize: 16, color: Colors.black)),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: _openGifticonSelectPage,
              child: Image.asset('assets/gift.png', width: 56, height: 56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGifticonGridItem(GroupGifticon item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageDetailPage(
              imagePath: item.imageUrl,
              groupName: groupName ?? '',
              gifticonId: item.gifticonId,
            ),
          ),
        );
      },
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 16 * 2 - 8 * 3) / 4,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item.imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildGifticonListItem(GroupGifticon item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageDetailPage(
              imagePath: item.imageUrl,
              groupName: groupName ?? '',
              gifticonId: item.gifticonId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Text(item.title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => setState(() => isGridView = true),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isGridView ? const Color(0xFF7081F1) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(
                'assets/menu1.png',
                width: 20,
                color: isGridView ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => isGridView = false),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: !isGridView ? const Color(0xFF7081F1) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(
                'assets/menu2.png',
                width: 20,
                color: !isGridView ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
