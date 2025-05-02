import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:typed_data';
import 'group.dart';
import 'brand.dart';

Widget _buildRoundedBox(
  BuildContext context,
  Widget destinationPage,
  int number,
) {
  String imagePath;
  Color boxColor = Colors.grey.shade300;

  // number 값에 따라 이미지 파일 경로를 다르게 설정
  if (number == 1) {
    imagePath = 'assets/group.png'; // 1번 박스 이미지
  } else if (number == 2) {
    imagePath = 'assets/time.png'; // 2번 박스 이미지
    boxColor = const Color(0xFF7081F1);
  } else {
    imagePath = 'assets/brand.png'; // 3번 박스 이미지
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destinationPage,
          transitionDuration: Duration.zero, // 전환 시간 0
          reverseTransitionDuration: Duration.zero, // 되돌아갈 때도 0
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
          width: 24, // 이미지 크기 조정
          height: 24,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

class Time extends StatefulWidget {
  const Time({super.key});

  @override
  State<Time> createState() => _TimeState();
}

class _TimeState extends State<Time> {
  List<AssetEntity> gifticonImages = [];

  final List<String> keywords = [
    '교환처',
    '유효기간',
    '주문번호',
    '상품명',
    'CU',
    'GS25',
    '올리브영',
    '스타벅스',
  ];

  Future<void> _scanGallery() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    final List<AssetEntity> allImages = await albums.first.getAssetListPaged(
      page: 0,
      size: 100,
    );

    final List<AssetEntity> filtered = [];

    for (final image in allImages) {
      final file = await image.originFile;
      if (file == null) continue;

      final inputImage = InputImage.fromFile(file);
      final recognizer = TextRecognizer(script: TextRecognitionScript.korean);
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();

      final text = result.text;
      if (keywords.any((k) => text.contains(k))) {
        filtered.add(image);
      }
    }

    // 최신순 정렬
    filtered.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    setState(() {
      gifticonImages = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 210, 101, 101),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Image.asset('assets/trash.png'),
                onPressed: () {
                  // TODO: trash 버튼 기능 추가
                },
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () {
                  // TODO: heart 버튼 기능 추가
                },
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () {
                  // TODO: account 버튼 기능 추가
                },
              ),
            ],
          ),
        ],
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildRoundedBox(context, Group(), 1),
                    const SizedBox(width: 8),
                    _buildRoundedBox(context, Time(), 2),
                    const SizedBox(width: 8),
                    _buildRoundedBox(context, Brand(), 3),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      gifticonImages.isEmpty
                          ? const Center(child: Text("기프티콘이 없습니다"))
                          : GridView.builder(
                            itemCount: gifticonImages.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemBuilder: (context, index) {
                              return FutureBuilder<Uint8List?>(
                                future: gifticonImages[index]
                                    .thumbnailDataWithSize(
                                      const ThumbnailSize(200, 200),
                                    ),
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return const Icon(
                                      Icons.image_not_supported,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),

          // 오른쪽 아래 renewal 오버레이 버튼
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: _scanGallery,
              child: Image.asset('assets/renewal.png', width: 56, height: 56),
            ),
          ),
        ],
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
                  // TODO: friendList 동작
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
}
