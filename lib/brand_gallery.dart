import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ImageDetailPage.dart';

class BrandGalleryPage extends StatefulWidget {
  final String brandName;

  const BrandGalleryPage({super.key, required this.brandName});

  @override
  State<BrandGalleryPage> createState() => _BrandGalleryPageState();
}

const String baseUrl = 'http://172.30.1.54:8080';

class BrandGifticon {
  final String gifticonId;
  final String title;
  final String imageUrl;
  final DateTime expiredAt;

  BrandGifticon({
    required this.gifticonId,
    required this.title,
    required this.imageUrl,
    required this.expiredAt,
  });

  factory BrandGifticon.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['imageUrl'];
    final fullImageUrl = rawImageUrl.startsWith('http')
        ? rawImageUrl
        : '$baseUrl$rawImageUrl';

    return BrandGifticon(
      gifticonId: json['gifticonNumber'] ?? '',
      title: json['brand'] ?? '제목 없음',
      imageUrl: fullImageUrl,
      expiredAt: DateTime.parse(json['dueDate']),
    );
  }

}

class _BrandGalleryPageState extends State<BrandGalleryPage> {
  bool isGridView = true;
  List<BrandGifticon> _gifticons = [];
  Map<String, List<BrandGifticon>> _groupedGifticons = {};

  @override
  void initState() {
    super.initState();
    _fetchGifticonsByBrand();
  }

  Future<void> _fetchGifticonsByBrand() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';
    final galleryUrl = Uri.parse('$baseUrl/api/gifticon/brand-gallery');

    try {
      final brandRes = await http.get(galleryUrl, headers: {
        'Authorization': 'Bearer $token',
      });

      if (brandRes.statusCode != 200) {
        print('📦 JWT 토큰: $token');
        print('❌ 브랜드 정보 불러오기 실패: ${brandRes.body}');
        return;
      }

      final jsonData = json.decode(brandRes.body);
      final List<dynamic> brands = jsonData['brands'];

      final targetBrand = brands.firstWhere(
        (b) => b['brand'] == widget.brandName,
        orElse: () => null,
      );

      if (targetBrand == null) {
        print('❌ 해당 브랜드 없음');
        return;
      }

      final List<String> gifticonNumbers = List<String>.from(targetBrand['gifticonNumbers'] ?? []);

      // 병렬 요청으로 상세 정보 가져오기
      final futures = gifticonNumbers.map((number) async {
        final detailUrl = Uri.parse('$baseUrl/api/gifticon/$number');
        final res = await http.get(detailUrl, headers: {
          'Authorization': 'Bearer $token',
        });

        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          return BrandGifticon.fromJson(data);
        } else {
          print('⚠️ 실패: $number → ${res.statusCode}');
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);
      final filteredGifticons = results.whereType<BrandGifticon>().toList();

      setState(() {
        _gifticons = filteredGifticons;
      });
      _groupGifticonsByDate(filteredGifticons);
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }



  void _groupGifticonsByDate(List<BrandGifticon> gifticons) {
    Map<String, List<BrandGifticon>> grouped = {};

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
          widget.brandName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildViewToggleButtons(),
          const SizedBox(height: 16),
          ..._groupedGifticons.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildGifticonGridItem(BrandGifticon item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageDetailPage(
              imagePath: item.imageUrl,
              groupName: widget.brandName,
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

  Widget _buildGifticonListItem(BrandGifticon item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageDetailPage(
              imagePath: item.imageUrl,
              groupName: widget.brandName,
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
