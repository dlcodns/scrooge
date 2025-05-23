import 'package:flutter/material.dart';
import 'ImageDetailPage.dart';

class BrandGalleryPage extends StatefulWidget {
  final String brandName;

  const BrandGalleryPage({super.key, required this.brandName});

  @override
  State<BrandGalleryPage> createState() => _BrandGalleryPageState();
}

class _BrandGalleryPageState extends State<BrandGalleryPage> {
  bool isGridView = true;

  final Map<String, List<Map<String, String>>> brandedCoupons = {
    "1월 31일 만료": [
      {"title": "복숭아 케이크", "image": "assets/twosome.png"},
    ],
    "2월 2일 만료": [
      {"title": "스타벅스 프라푸치노", "image": "assets/starbucks.png"},
      {"title": "GS25 5천원권", "image": "assets/GS25.png"},
    ],
    "3월 만료": [
      {"title": "맥카페 아이스커피", "image": "assets/mcdonalds.png"},
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // 중앙 정렬
        leading: const BackButton(color: Colors.black), // 왼쪽 고정
        title: Center(
          child: Text(
            widget.brandName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildViewToggleButtons(),
          const SizedBox(height: 16),
          ...brandedCoupons.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                isGridView
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((item) => _buildMaxWidthSquareImage(item)).toList(),
                      )
                    : Column(
                        children: entry.value.map((item) => _buildCouponListTile(item)).toList(),
                      ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMaxWidthSquareImage(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageDetailPage(
              imagePath: item["image"] ?? "",
              groupName: widget.brandName,
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
            child: Image.asset(
              item["image"] ?? "",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponListTile(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageDetailPage(
              imagePath: item["image"] ?? "",
              groupName: widget.brandName,
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
              child: Image.asset(
                item["image"] ?? "",
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["title"] ?? "", style: const TextStyle(fontSize: 14)),
              ],
            )
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
