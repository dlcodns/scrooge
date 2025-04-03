import 'package:flutter/material.dart';

class FavoriteGiftcornScreen extends StatefulWidget {
  final String nickname;

  FavoriteGiftcornScreen({required this.nickname});

  @override
  _FavoriteGiftcornScreenState createState() => _FavoriteGiftcornScreenState();
}

class _FavoriteGiftcornScreenState extends State<FavoriteGiftcornScreen> {
  final List<String> keywords = [
    "치킨", "배민 상품권", "쿠키", "인테리어", "커피", "편의점", "떡볶이", "케이크"
  ];

  List<String?> selectedKeywords = [null, null, null];
  List<TextEditingController> controllers =
      List.generate(3, (_) => TextEditingController());

  void toggleKeyword(String keyword) {
    final index = selectedKeywords.indexOf(keyword);

    setState(() {
      if (index != -1) {
        // 이미 선택되어 있으면 해제
        selectedKeywords[index] = null;
        controllers[index].clear();
      } else {
        // 빈 자리 찾기
        final emptyIndex = selectedKeywords.indexOf(null);
        if (emptyIndex != -1) {
          selectedKeywords[emptyIndex] = keyword;
          controllers[emptyIndex].text = keyword;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SizedBox.shrink(),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "${widget.nickname}님이 선호하는\n기프티콘을 알려주세요!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045),
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
                            color: selectedKeywords[index] != null
                                ? Colors.black
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Text(
                "직접 입력하거나 아래에서 선택해보세요!",
                style: TextStyle(
                    color: Colors.black, fontSize: screenWidth * 0.035),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Wrap(
              spacing: screenWidth * 0.03,
              runSpacing: screenHeight * 0.015,
              children: keywords.map((text) {
                final isSelected = selectedKeywords.contains(text);
                return ChoiceChip(
                  label: Text(text,
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: isSelected ? Colors.white : Colors.black)),
                  selected: isSelected,
                  selectedColor: Colors.indigo,
                  backgroundColor: Colors.grey[200],
                  onSelected: (_) => toggleKeyword(text),
                );
              }).toList(),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 저장 후 뒤로
                },
                child: Text("저장",
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
