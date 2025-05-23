import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ImageDetailPage.dart';
import 'image_ocr.dart';

class GroupGalleryPage extends StatefulWidget {
  final String groupName;

  const GroupGalleryPage({super.key, required this.groupName});

  @override
  State<GroupGalleryPage> createState() => _GroupGalleryPageState();
}

class _GroupGalleryPageState extends State<GroupGalleryPage> {
  bool isGridView = true;
  bool showDrawer = false;

  final Map<String, List<Map<String, String>>> groupedCoupons = {
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

  final List<String> members = ["박형우", "송영은"];

  void _pickGifticonImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // TODO: 저장 및 표시 추가
      debugPrint("선택된 이미지 경로: ${picked.path}");
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
          widget.groupName,
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
              ...groupedCoupons.entries.map((entry) {
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
              onTap: _pickGifticonImage,
              child: Image.asset('assets/gift.png', width: 56, height: 56),
            ),
          ),
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
              groupName: widget.groupName,
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
              groupName: widget.groupName,
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