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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'gifticon_state.dart';



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
  List<String> gifticonSummaries = [];

  final List<String> keywords = [
    '교환처',
    '유효기간',
    // '주문번호',
    '상품명',
    // 'CU',
    // 'GS25',
    // '올리브영',
    //'kakaotalk',
  ];

  void _updateGifticons(List<AssetEntity> resultImages) {
    final state = Provider.of<GifticonState>(context, listen: false);
    state.update(resultImages);
  }


  Future<void> _sendGifticonToServer(String text) async {
    final brand = _extractAfterKeyword(text, "교환처");
    final dueDateStr = _extractAfterKeyword(text, "유효기간");
    final orderNumber = _extractAfterKeyword(text, "주문번호");

    if (brand == null || dueDateStr == null || orderNumber == null) return;

    // final response = await http.post(
    //   Uri.parse('http://192.168.84.121:8080/api/gifticons'),
    //   headers: {"Content-Type": "application/json"},
    //   body: jsonEncode({
    //     "gifticonNumber": orderNumber,
    //     "brand": brand,
    //     "dueDate": dueDateStr,
    //     "productName": null,
    //     "whichRoom": null,
    //     "whoPost": null, // 실제 ID로 대체
    //   }),
    // );

    gifticonSummaries.add(
  "${gifticonSummaries.length + 1}번 기프티콘: "
  "gifticonNumber: $orderNumber, brand: $brand, dueDate: $dueDateStr, "
  "productName: null, whichRoom: null, whoPost: null"
);

    debugPrint("서버 전송 생략 — 임시 저장된 기프티콘 정보: \${gifticonSummaries.last}");
    // debugPrint("서버 응답: ${response.statusCode}");
  }


  String? _extractAfterKeyword(String text, String keyword) {
    final regex = RegExp('$keyword[:\\s]*([^\n]+)');
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim();
  }


  DateTime? _parseKoreanDate(String input) {
    try {
      final regex = RegExp(r'(\d{4})[년.-/ ]+(\d{1,2})[월.-/ ]+(\d{1,2})');
      final match = regex.firstMatch(input);
      if (match != null) {
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }


  Future<String> _callGoogleVisionAPI(Uint8List imageBytes) async {
    const apiKey = 'AIzaSyDtG9EgGBrKJzkWuAfNLabWZwNiqhV2tM8'; // 🔒 실제 API 키 입력
    final url = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey');
    final requestPayload = {
      "requests": [
        {
          "image": {"content": base64Encode(imageBytes)},
          "features": [{"type": "TEXT_DETECTION"}]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['responses'][0]['fullTextAnnotation']?['text'] ?? '';
    } else {
      return '';
    }
  }



  Future<void> _scanGallery() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        debugPrint('❌ 권한 없음: 갤러리 접근 거부됨');
        return;
      }

      final DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 1));


      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          createTimeCond: DateTimeCond(min: oneMonthAgo, max: DateTime.now()),
        ),
      );

      if (albums.isEmpty) return;


      final List<AssetEntity> allImages = await albums.first.getAssetListPaged(page: 0, size: 100);
      final List<AssetEntity> resultImages = [];


      for (final image in allImages) {
        final file = await image.originFile;
        if (file == null) continue;

        final bytes = await file.readAsBytes();
        final extractedText = await _callGoogleVisionAPI(bytes);

        if (extractedText.contains("교환처") || extractedText.contains("유효기간") || extractedText.contains("주문번호")) {
          resultImages.add(image);
          await _sendGifticonToServer(extractedText);

        }
      }

      _updateGifticons(resultImages); // Provider 상태 동기화

    } catch (e) {
      debugPrint("❌ 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final gifticonImages = Provider.of<GifticonState>(context).gifticons;
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
                  Navigator.pushNamed(context, '/notifications');
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
                                            builder:
                                                (_) => GifticonViewer(
                                                  asset: gifticonImages[index],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey.shade200,
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: AspectRatio(
                                          aspectRatio: 1, // ✅ 정사각형
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            alignment:
                                                Alignment.topCenter, // ✅ 윗부분 기준
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
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 92,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: gifticonSummaries.map((summary) => Text(
                      summary,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    )).toList(),
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
                child: Image.file(snapshot.data!, fit: BoxFit.contain),
              ),
            ),
          );
        } else {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Icon(Icons.broken_image, color: Colors.white)),
          );
        }
      },
    );
  }
}
