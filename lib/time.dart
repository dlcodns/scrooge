import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
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
import 'screens/notification_screen.dart';
import 'gifticon_state.dart';
import 'package:shared_preferences/shared_preferences.dart';



Widget _buildRoundedBox(
  BuildContext context,
  Widget destinationPage,
  int number,
) {
  String imagePath;
  Color boxColor = Colors.grey.shade300;

  if (number == 1) {
    imagePath = 'assets/group.png';
  } else if (number == 2) {
    imagePath = 'assets/time.png'; 
    boxColor = const Color(0xFF7081F1);
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

class Time extends StatefulWidget {
  const Time({super.key});

  @override
  State<Time> createState() => _TimeState();
}

List<String> serverImageUrls = [];

class _TimeState extends State<Time> {
  List<String> gifticonSummaries = [];

  @override
  void initState() {
    super.initState();
    _fetchMyGifticons();
  }

  Future<void> _fetchMyGifticons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://172.30.1.54:8080/api/group/my-gifticons'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        serverImageUrls = data.map((e) {
          final url = e['imageUrl'];
          return url.startsWith('http') ? url : 'http://172.30.1.54:8080$url';
        }).cast<String>().toList();
      });
    }
  }


  final List<String> keywords = [
    '교환처',
    '유효기간',
    '상품명'
  ];

  void _updateGifticons(List<AssetEntity> resultImages) {
    final state = Provider.of<GifticonState>(context, listen: false);
    state.update(resultImages);
  }

  String? getTextAfterKeyword(String text, String keyword) {
    final regex = RegExp('$keyword[:\\s]*([^\n]+)');
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? normalizeDate(String? raw) {
  if (raw == null) return null;

  final match = RegExp(r'(\d{4})[년.\- ]+(\d{1,2})[월.\- ]+(\d{1,2})[일.\- ]*').firstMatch(raw);
  if (match != null) {
    final year = match.group(1);
    final month = match.group(2)!.padLeft(2, '0');
    final day = match.group(3)!.padLeft(2, '0');
    return "$year-$month-$day";
  }

  return raw;
}


  String? extractGifticonNumber(String text) {
    final match = RegExp(r'\d{4} \d{4} \d{4,8}').firstMatch(text);
    return match?.group(0);
  }



  Future<void> _sendGifticonToServer(String text, File imageFile) async {
    final brand = getTextAfterKeyword(text, "교환처");
    final rawDueDate = getTextAfterKeyword(text, "유효기간");
    final dueDateStr = normalizeDate(rawDueDate);
    final orderNumber = extractGifticonNumber(text);

    if (brand == null || dueDateStr == null || orderNumber == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    if (token == null) return;

    final url = Uri.parse('http://172.30.1.54:8080/api/gifticon');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['data'] = jsonEncode({
        "gifticonNumber": orderNumber,
        "brand": brand,
        "dueDate": dueDateStr,
      })
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      gifticonSummaries.add(
        "${gifticonSummaries.length + 1}번 기프티콘:\n"
        "- gifticonNumber: $orderNumber\n"
        "- brand: $brand\n"
        "- dueDate: $dueDateStr",
      );
      debugPrint("✅ 서버 저장 성공");
    } else {
      debugPrint("❌ 서버 저장 실패: ${response.statusCode}");
    }
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
          await _sendGifticonToServer(extractedText, file);

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
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrashScreen()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPageScreen()),
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
                // 상단 라운드 버튼들
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

                // // ✅ OCR 결과 요약 텍스트 출력
                // if (gifticonSummaries.isNotEmpty)
                //   Container(
                //     width: double.infinity,
                //     margin: const EdgeInsets.only(bottom: 8),
                //     padding: const EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       color: Colors.grey.shade100,
                //       border: Border.all(color: Colors.black12),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: gifticonSummaries.map((summary) => Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 4),
                //         child: Text(
                //           summary,
                //           style: const TextStyle(
                //             fontSize: 13,
                //             color: Colors.black87,
                //           ),
                //         ),
                //       )).toList(),
                //     ),
                //   ),

                Expanded(
                  child: gifticonImages.isEmpty && serverImageUrls.isEmpty
                      ? const Center(child: Text("기프티콘이 없습니다"))
                      : GridView.builder(
                          itemCount: serverImageUrls.length + gifticonImages.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemBuilder: (context, index) {
                            if (index < serverImageUrls.length) {
                              // 서버에서 가져온 이미지 처리
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(
                                    serverImageUrls[index],
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              );
                            } else {
                              // 로컬 갤러리에서 가져온 이미지 처리
                              final assetIndex = index - serverImageUrls.length;
                              return FutureBuilder<Uint8List?>(
                                future: gifticonImages[assetIndex]
                                    .thumbnailDataWithSize(const ThumbnailSize(500, 500)),
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasData) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GifticonViewer(
                                              asset: gifticonImages[assetIndex],
                                            ),
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
                                          aspectRatio: 1,
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Icon(Icons.image_not_supported);
                                  }
                                },
                              );
                            }
                          },
                        ),
                )

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
