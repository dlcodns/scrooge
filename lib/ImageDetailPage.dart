import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> saveImageToGallery(String assetPath) async {
  final status = await Permission.photos.request(); // Android 13 이상
  final legacyStatus = await Permission.storage.request(); // Android 12 이하

  if (!status.isGranted && !legacyStatus.isGranted) {
    Fluttertoast.showToast(msg: "갤러리 저장 권한이 필요합니다");
    return;
  }

  try {
    final ByteData bytes = await rootBundle.load(assetPath);
    final Uint8List list = bytes.buffer.asUint8List();

    final result = await ImageGallerySaverPlus.saveImage(
      list,
      name: "gifticon_${DateTime.now().millisecondsSinceEpoch}",
      isReturnImagePathOfIOS: true,
      quality: 100,
    );

    if (result['isSuccess'] == true || result['filePath'] != null) {
      Fluttertoast.showToast(msg: "이미지가 갤러리에 저장되었습니다");
    } else {
      Fluttertoast.showToast(msg: "이미지 저장에 실패했습니다");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "오류 발생: ${e.toString()}");
  }
}

class ImageDetailPage extends StatelessWidget {
  final String imagePath;
  final String groupName;
  final String gifticonId;

  const ImageDetailPage({
    super.key,
    required this.imagePath,
    required this.groupName,
    required this.gifticonId,
  });

  Future<void> markAsUsed(BuildContext context) async {
    final url = Uri.parse("http://172.30.1.54:8080/api/mypage/trash");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer YOUR_TOKEN", // 필요한 경우 추가
        },
        body: jsonEncode({
          "gifticonId": gifticonId,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "사용 완료로 처리되었습니다.");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "처리 실패: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "오류 발생: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: const BackButton(color: Colors.black),
        title: Text(
          groupName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7081F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    saveImageToGallery(imagePath);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("이미지 저장", style: TextStyle(color: Colors.white)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7081F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    markAsUsed(context); // ✅ gifticonId만 전송
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("사용 완료", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
