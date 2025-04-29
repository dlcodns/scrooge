import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 추가
import 'profile.dart';
import 'edit_password.dart';
import 'trash_manage.dart';

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool showNotificationSetting = false;
  int selectedDay = 3;
  String selectedPeriod = '오후';
  int selectedHour = 8;

  List<int> days = [1, 2, 3, 4, 5, 6, 7];
  List<String> periods = ['오전', '오후'];
  List<int> hours = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("마이페이지",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text("내 프로필 정보",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: TextButton(
                onPressed: () {},
                child: Text("로그아웃",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDetailScreen()),
                );
              },
            ),
            Divider(
              thickness: 1.5,
              color: Colors.black,
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.black),
              title: Text("유효기간 만료 알림 설정",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                setState(() {
                  showNotificationSetting = !showNotificationSetting;
                });
              },
            ),
            if (showNotificationSetting)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: days.indexOf(selectedDay),
                              ),
                              itemExtent: 32,
                              magnification: 1.2,
                              useMagnifier: true,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedDay = days[index];
                                });
                              },
                              children: days
                                  .map((d) => Center(
                                        child: Text(
                                          "$d일 전",
                                          style: GoogleFonts.jua(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: periods.indexOf(selectedPeriod),
                              ),
                              itemExtent: 32,
                              magnification: 1.2,
                              useMagnifier: true,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedPeriod = periods[index];
                                });
                              },
                              children: periods
                                  .map((p) => Center(
                                        child: Text(
                                          p,
                                          style: GoogleFonts.jua(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: hours.indexOf(selectedHour),
                              ),
                              itemExtent: 32,
                              magnification: 1.2,
                              useMagnifier: true,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedHour = hours[index];
                                });
                              },
                              children: hours
                                  .map((h) => Center(
                                        child: Text(
                                          "$h시",
                                          style: GoogleFonts.jua(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNotificationSetting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "$selectedDay일 전 $selectedPeriod $selectedHour시에 알림이 설정되었습니다.",
                            ),
                          ),
                        );
                      },
                      child: Text("확인",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: Size(double.infinity, 40),
                      ),
                    )
                  ],
                ),
              ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.black),
              title: Text("비밀번호 변경",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditPasswordScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.black),
              title: Text("휴지통", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrashScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text("탈퇴하기", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
