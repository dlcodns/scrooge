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

  void toggleKeyword(String keyword) {
    final index = selectedKeywords.indexOf(keyword);

    setState(() {
      if (index != -1) {
        selectedKeywords[index] = null;
      } else {
        final emptyIndex = selectedKeywords.indexOf(null);
        if (emptyIndex != -1) {
          selectedKeywords[emptyIndex] = keyword;
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
                                : Colors.grey[400],
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
                  // null 제거 후 전달
                  Navigator.pop(
                    context,
                    selectedKeywords.map((e) => e ?? "_____").toList(),
                  );
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

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController =
      TextEditingController(text: "이채운");

  List<String> favoriteGiftcorns = ["쿠키", "올리브영", "루썸플레이스"]; // 기본값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "내 프로필 정보 수정",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("이름",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "이름을 입력하세요",
                hintStyle: TextStyle(fontWeight: FontWeight.bold),
                suffixIcon: Icon(Icons.edit, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            SizedBox(height: 24),
            Text("이모티콘",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Icon(Icons.emoji_emotions, size: 28),
                  SizedBox(height: 8),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/image.png"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // 선호 기프티콘 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "선호 기프티콘",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteGiftcornScreen(
                          nickname: nameController.text,
                        ),
                      ),
                    );
                    if (result != null && result is List<String>) {
                      setState(() {
                        favoriteGiftcorns = result;
                      });
                    }
                  },
                  child: Text("다시하기",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("1순위    ${favoriteGiftcorns[0]}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("2순위    ${favoriteGiftcorns[1]}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("3순위    ${favoriteGiftcorns[2]}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("확인",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[400],
                  padding:
                      EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
