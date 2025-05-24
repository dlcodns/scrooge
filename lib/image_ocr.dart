import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudVisionOCRPage extends StatefulWidget {
  const CloudVisionOCRPage({super.key});

  @override
  State<CloudVisionOCRPage> createState() => _CloudVisionOCRPageState();
}

class _CloudVisionOCRPageState extends State<CloudVisionOCRPage> {
  File? _image; // 모바일에서 사용
  Uint8List? _webImageBytes; // 웹에서 사용
  String _resultText = '';
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
        await _callGoogleVisionAPI(bytes); // 웹은 bytes 직접 전달
      } else {
        setState(() {
          _image = File(pickedFile.path);
        });
        final bytes = await File(pickedFile.path).readAsBytes();
        await _callGoogleVisionAPI(bytes);
      }
    }
  }

  Future<void> _callGoogleVisionAPI(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    const apiKey = ''; // 🔐 실제 API 키로 대체할 것
    final url = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

    final requestPayload = {
      "requests": [
        {
          "image": {"content": base64Image},
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
      final text = data['responses'][0]['fullTextAnnotation']?['text'] ?? 'No text found.';
      setState(() => _resultText = text);
    } else {
      setState(() => _resultText = 'Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (kIsWeb && _webImageBytes != null) {
      imageWidget = Image.memory(_webImageBytes!, height: 200);
    } else if (!kIsWeb && _image != null) {
      imageWidget = Image.file(_image!, height: 200);
    } else {
      imageWidget = const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Google OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickImage, child: const Text('이미지 선택')),
            const SizedBox(height: 20),
            imageWidget,
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_resultText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
