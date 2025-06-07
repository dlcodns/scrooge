import 'package:flutter/material.dart';
import 'favorite_giftcorn.dart';

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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          '내 프로필 정보 수정',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
