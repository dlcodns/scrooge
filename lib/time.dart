import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:typed_data';
import 'group.dart';
import 'brand.dart';
import 'screens/friend_list_screen.dart';
import 'mypage.dart';
import 'trash_manage.dart';
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
    'kakaotalk',
    'BBQ',
  ];

  Future<void> _scanGallery() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        debugPrint('❌ 권한 없음: 갤러리 접근 거부됨');
        return;
      } else {
        debugPrint('✅ 권한 허용됨: 갤러리 접근 가능');
      }

      final DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 3));

      final FilterOptionGroup filterOption = FilterOptionGroup(
        imageOption: const FilterOption(needTitle: false),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
        createTimeCond: DateTimeCond(
          min: oneMonthAgo,
          max: DateTime.now(),
        ),
      );

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: filterOption,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        debugPrint('⚠️ 1개월 이내 이미지 없음');
        return;
      }

      final List<AssetEntity> recentImages = await albums.first.getAssetListPaged(
        page: 0,
        size: 99999,
      );

      debugPrint('📅 한 달 이내 이미지 수: ${recentImages.length}');


      final List<AssetEntity> filtered = [];
      int index = 0;

      for (final image in recentImages) {
        try {
          if (image.createDateTime.isBefore(oneMonthAgo)) {
            debugPrint('⏳ $index번 이미지 제외: 1개월 이전');
            index++;
            continue;
          }

          final file = await image.originFile;
          if (file == null) {
            debugPrint('🚫 $index번 이미지 파일 없음');
            index++;
            continue;
          }

          final inputImage = InputImage.fromFile(file);
          final recognizer = TextRecognizer();
          final result = await recognizer.processImage(inputImage);

          final text = result.text;
          debugPrint('🔍 $index번 OCR 결과: $text');

          if (keywords.any((k) => text.contains(k))) {
            filtered.add(image);
            debugPrint('✅ $index번 이미지 추가됨');
          }

          await recognizer.close();
        } catch (e) {
          debugPrint('❌ $index번 이미지 처리 중 오류: $e');
        }

        index++;
      }

      debugPrint('📦 최종 필터링 이미지 수: ${filtered.length}');

      setState(() {
        gifticonImages = filtered;
      });
    } catch (e) {
      debugPrint('🚨 갤러리 전체 처리 실패: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrashScreen()),
    );
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
          // 👉 마이페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyPageScreen()),
          );
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
                                      const ThumbnailSize(500, 500),
                                    ),
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasData) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GifticonViewer(asset: gifticonImages[index]),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.grey.shade200,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: AspectRatio(
                                            aspectRatio: 1, // ✅ 정사각형
                                            child: Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter, // ✅ 윗부분 기준
                                            ),
                                          ),
                                        ),
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
}

class GifticonViewer extends StatelessWidget {
  final AssetEntity asset;

  const GifticonViewer({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: asset.originFile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.file(
                  snapshot.data!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Icon(Icons.broken_image, color: Colors.white),
            ),
          );
        }
      },
    );
  }
}

