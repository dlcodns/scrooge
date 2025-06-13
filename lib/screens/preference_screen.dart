import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../group.dart';

class PreferenceScreen extends StatefulWidget {
  final String nickname;
  final String token;
  final int userId;

  const PreferenceScreen({
    required this.nickname,
    required this.token,
    required this.userId,
    super.key,
  });

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final List<String> keywords = [
    "치킨",
    "배민 상품권",
    "쿠키",
    "인테리어",
    "커피",
    "편의점",
    "떡볶이",
    "케이크",
  ];

  final Map<String, int> keywordIdMap = {
    "치킨": 1,
    "커피": 2,
    "떡볶이": 3,
    "쿠키": 4,
    "편의점": 5,
    "케이크": 6,
    "배민 상품권": 7,
    "인테리어": 8,
  };

  List<String?> selectedKeywords = [null, null, null];

  @override
  void initState() {
    super.initState();
    // 통신 필요 없으니 아무것도 안 해도 됨
  }

  void toggleKeyword(String keyword) {
    final index = selectedKeywords.indexOf(keyword);
    setState(() {
      if (index != -1) {
        selectedKeywords[index] = null;
      } else {
        if (selectedKeywords.contains(keyword)) return;
        final emptyIndex = selectedKeywords.indexOf(null);
        if (emptyIndex != -1) {
          selectedKeywords[emptyIndex] = keyword;
        }
      }
    });
  }

  Future<void> savePreferences() async {
    if (selectedKeywords.any((k) => k == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('3개의 키워드를 모두 선택해주세요')));
      return;
    }

    final url = Uri.parse('http://172.30.129.19:8080/api/preferences');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'firstKeywordId': keywordIdMap[selectedKeywords[0]]!,
        'secondKeywordId': keywordIdMap[selectedKeywords[1]]!,
        'thirdKeywordId': keywordIdMap[selectedKeywords[2]]!,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Group(token: widget.token, userId: widget.userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요')));
    }

    print("📦 선호 저장 후 이동하는 userId: ${widget.userId}");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.015,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "${widget.nickname}님이 선호하는\n기프티콘을 알려주세요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: Column(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${index + 1}순위    ",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            selectedKeywords[index] ?? "_____",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: Text(
                  "아래에서 3개를 골라주세요!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Wrap(
                spacing: screenWidth * 0.03,
                runSpacing: screenHeight * 0.015,
                alignment: WrapAlignment.center,
                children:
                    keywords.map((text) {
                      final isSelected = selectedKeywords.contains(text);
                      return ChoiceChip(
                        label: Text(
                          text,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.indigo,
                        backgroundColor: Colors.grey[200],
                        onSelected: (_) => toggleKeyword(text),
                      );
                    }).toList(),
              ),
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: ElevatedButton(
                  onPressed: savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[400],
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.2,
                      vertical: screenHeight * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                  ),
                  child: Text(
                    "저장",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
