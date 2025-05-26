import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'profile.dart';
import 'edit_password.dart';
import 'trash_manage.dart';

class Item {
  final String name;
  final DateTime expiryDate;

  Item({required this.name, required this.expiryDate});
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<int> scheduleNotification(String content, DateTime expiryDate, int daysBefore, String period, int hour) async {
  DateTime targetDate = expiryDate.subtract(Duration(days: daysBefore));
  int notifyHour = (period == '오전') ? hour : hour + 12;

  DateTime notificationDateTime = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
    notifyHour,
  );

  int id = notificationDateTime.hashCode;

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    '유효기간 알림',
    content,
    tz.TZDateTime.from(notificationDateTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails('your_channel_id', 'your_channel_name'),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ 추가된 필수 항목
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );


  return id;
}

Future<void> scheduleAllExpiryNotifications({
  required List<Item> items,
  required int selectedDay,
  required String selectedPeriod,
  required int selectedHour,
  required Function(int) onNotificationScheduled,
}) async {
  for (var item in items) {
    int id = await scheduleNotification(
      '${item.name}의 유효기간이 임박했습니다!',
      item.expiryDate,
      selectedDay,
      selectedPeriod,
      selectedHour,
    );
    onNotificationScheduled(id);
  }
}

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
  List<String> notificationSummaries = [];
  List<int> notificationIds = [];

  List<Item> items = [
    Item(name: '우유', expiryDate: DateTime.now().add(Duration(days: 5))),
    Item(name: '계란', expiryDate: DateTime.now().add(Duration(days: 2))),
    Item(name: '치즈', expiryDate: DateTime.now().add(Duration(days: 7))),
    Item(name: '기프트콘', expiryDate: DateTime(2025, 5, 25)), // ✅ 기프트콘 추가
  ];

  @override
  void initState() {
    super.initState();
    initializeNotification();

    // ✅ 기프트콘 알림 테스트: 2025년 5월 25일 만료 → 4일 전 오후 8시 알림
    scheduleNotification(
      "기프트콘의 유효기간이 곧 만료됩니다!",
      DateTime(2025, 5, 25),
      4,
      '오후',
      8,
    );
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
        title: Text(
          '마이페이지',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            Divider(thickness: 1.5, color: Colors.black),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
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
                                        child: Text("$d일 전", style: GoogleFonts.jua(fontSize: 18)),
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
                                        child: Text(p, style: GoogleFonts.jua(fontSize: 18)),
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
                                        child: Text("$h시", style: GoogleFonts.jua(fontSize: 18)),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showNotificationSetting = false;
                          String summary = "$selectedDay일 전 $selectedPeriod $selectedHour시";
                          notificationSummaries.add(summary);
                        });

                        await scheduleAllExpiryNotifications(
                          items: items,
                          selectedDay: selectedDay,
                          selectedPeriod: selectedPeriod,
                          selectedHour: selectedHour,
                          onNotificationScheduled: (id) {
                            notificationIds.add(id);
                          },
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("모든 아이템에 대해 알림이 설정되었습니다.")),
                        );
                      },
                      child: Text("전체 알림 설정", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              title: Text("비밀번호 변경", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditPasswordScreen()),
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
            if (notificationSummaries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(thickness: 1.5, color: Colors.black),
                    Text("설정된 알림 목록", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            await flutterLocalNotificationsPlugin.cancel(notificationIds[index]);
                            setState(() {
                              notificationSummaries.removeAt(index);
                              notificationIds.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("알림이 삭제되었습니다.")),
                            );
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
