import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

import 'notification.dart';
import 'profile.dart';
import 'edit_password.dart';
import 'trash_manage.dart';

class Item {
  final String name;
  final DateTime expiryDate;

  Item({required this.name, required this.expiryDate});
}

class Gifticon {
  final String name;
  final DateTime dueDate;

  Gifticon({required this.name, required this.dueDate});

  factory Gifticon.fromJson(Map<String, dynamic> json) {
    return Gifticon(
      name: json['brand'],
      dueDate: DateTime.parse(json['dueDate']),
    );
  }
}

class MyPageScreen extends StatefulWidget {
  final String token;
  const MyPageScreen({required this.token, Key? key}) : super(key: key);

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool showNotificationSetting = false;
  int selectedDay = 3;
  List<int> days = [1, 2, 3, 4, 5, 6, 7];
  List<String> notificationSummaries = [];
  List<int> notificationIds = [];
  List<Gifticon> myGifticons = [];

  @override
  void initState() {
    super.initState();
    initializeNotification();
    _loadSavedNotifications();
    _loadGifticons();
  }

  Future<void> _loadSavedNotifications() async {
    final summaries = await loadSavedSummaries();
    final ids = await loadSavedNotificationIds();
    setState(() {
      notificationSummaries = summaries;
      notificationIds = ids;
    });
  }

  Future<void> saveAll() async {
    await saveNotifications(notificationSummaries, notificationIds);
  }

  Future<void> _loadGifticons() async {
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(widget.token);
      String myUserId = payload['sub'];
      final gifticons = await fetchMyGifticons(widget.token, myUserId);
      setState(() {
        myGifticons = gifticons;
      });
    } catch (e) {
      print('❌ 기프트콘 로딩 오류: $e');
    }
  }

  Future<List<Gifticon>> fetchMyGifticons(String token, String myUserId) async {
    final baseUrl = await getLocalServerBaseUrl();
    final response = await http.get(
      Uri.parse('$baseUrl/api/brand-gallery'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> brands = data['brands'];

      List<Gifticon> myGifticons = [];

      for (var brand in brands) {
        final List<dynamic> gifticons = brand['gifticons'];
        for (var gifticon in gifticons) {
          if (gifticon['posterUserId'] == myUserId) {
            myGifticons.add(Gifticon.fromJson(gifticon));
          }
        }
      }

      return myGifticons;
    } else {
      throw Exception("기프트콘 데이터를 불러오는 데 실패했습니다.");
    }
  }

  Future<void> scheduleAllExpiryNotifications({
    required List<Item> items,
    required int selectedDay,
    required Function(int) onNotificationScheduled,
  }) async {
    for (var item in items) {
      int id = await scheduleNotification(
        '${item.name}의 유효기간이 임박했습니다!',
        item.expiryDate,
        selectedDay,
      );
      if (id != -1) {
        onNotificationScheduled(id);
      }
    }
  }

  Future<String> getLocalServerBaseUrl() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && addr.address.startsWith("172.")) {
          final segments = addr.address.split('.');
          if (segments.length == 4) {
            return "http://${segments[0]}.${segments[1]}.${segments[2]}.1:8080";
          }
        }
      }
    }
    return "http://10.0.2.2:8080";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          '마이페이지',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text("내 프로필 정보", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: TextButton(
                onPressed: () {},
                child: Text("로그아웃", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDetailScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.black),
              title: Text("유효기간 만료 알림 설정", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("설정된 알림 수: ${notificationSummaries.length}/3"),
              onTap: () {
                setState(() {
                  showNotificationSetting = !showNotificationSetting;
                });
              },
            ),
            if (showNotificationSetting)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: days.indexOf(selectedDay)),
                        itemExtent: 32,
                        magnification: 1.2,
                        useMagnifier: true,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedDay = days[index];
                          });
                        },
                        children: days
                            .map((d) => Center(child: Text("$d일 전", style: GoogleFonts.jua(fontSize: 18))))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        String summary = "$selectedDay일 전 오전 9시";
                        if (notificationSummaries.length >= 3) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("최대 3개의 알림만 설정할 수 있습니다.")));
                          return;
                        }
                        if (notificationSummaries.contains(summary)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("이미 동일 날짜의 알림이 존재합니다.")));
                          return;
                        }
                        await scheduleAllExpiryNotifications(
                          items: myGifticons.map((g) => Item(name: g.name, expiryDate: g.dueDate)).toList(),
                          selectedDay: selectedDay,
                          onNotificationScheduled: (id) {
                            notificationIds.add(id);
                          },
                        );
                        setState(() {
                          notificationSummaries.add(summary);
                        });
                        await saveAll();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("기프트콘 유효기간 알림이 설정되었습니다.")));
                      },
                      child: Text("전체 알림 설정", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: Size(double.infinity, 40)),
                    )
                  ],
                ),
              ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.black),
              title: Text("비밀번호 변경", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditPasswordScreen(token: widget.token)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.black),
              title: Text("휴지통", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrashScreen(token: widget.token)),
                );
              },
            ),
            if (notificationSummaries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(thickness: 1.5, color: Colors.black),
                    Text("설정된 알림 목록 (${notificationSummaries.length}/3)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: notificationSummaries.length,
                      itemBuilder: (context, index) {
                        final summary = notificationSummaries[index];
                        return Dismissible(
                          key: Key(summary + index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) async {
                            await cancelNotification(notificationIds[index]);
                            setState(() {
                              notificationSummaries.removeAt(index);
                              notificationIds.removeAt(index);
                            });
                            await saveAll();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("알림이 삭제되었습니다.")));
                          },
                          child: ListTile(
                            leading: Icon(Icons.alarm, color: Colors.indigo),
                            title: Text(summary),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
