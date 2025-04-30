import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification.dart';

class Item {
  final String name;
  final DateTime expiryDate;

  Item({required this.name, required this.expiryDate});
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
  List<String> notificationSummaries = [];

  List<int> days = [1, 2, 3, 4, 5, 6, 7];
  List<String> periods = ['오전', '오후'];
  List<int> hours = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  List<Item> items = [
    Item(name: '우유', expiryDate: DateTime.now().add(Duration(days: 7))),
    Item(name: '계란', expiryDate: DateTime.now().add(Duration(days: 10))),
  ];

  void scheduleExpiryNotification(Item item) async {
    final scheduled = item.expiryDate.subtract(Duration(days: selectedDay));
    final hour = selectedPeriod == '오후' ? selectedHour + 12 : selectedHour;
    final scheduledTime = DateTime(
      scheduled.year,
      scheduled.month,
      scheduled.day,
      hour,
      0,
    );

    await FlutterLocalNotification.scheduleNotification(scheduledTime);

    setState(() {
      notificationSummaries.add("${item.name} - $selectedDay일 전 $selectedPeriod $selectedHour시 알림 설정됨");
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("알림이 예약되었습니다.")),
    );
  }

  @override
  void initState() {
    super.initState();
    FlutterLocalNotification.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
      ),
      body: ListView(
        children: [
          ...items.map((item) => ListTile(
                title: Text(item.name),
                subtitle: Text("유효기간: \${item.expiryDate.toLocal()}"),
                trailing: IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    setState(() {
                      showNotificationSetting = true;
                    });
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('알림 설정 - ${item.name}'),
                        content: SizedBox(
                          height: 200,
                          child: Row(
                            children: [
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: days.indexOf(selectedDay),
                                  ),
                                  itemExtent: 32,
                                  onSelectedItemChanged: (i) => selectedDay = days[i],
                                  children: days
                                      .map((d) => Text("$d일 전", style: GoogleFonts.jua(fontSize: 18)))
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: periods.indexOf(selectedPeriod),
                                  ),
                                  itemExtent: 32,
                                  onSelectedItemChanged: (i) => selectedPeriod = periods[i],
                                  children: periods
                                      .map((p) => Text(p, style: GoogleFonts.jua(fontSize: 18)))
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: hours.indexOf(selectedHour),
                                  ),
                                  itemExtent: 32,
                                  onSelectedItemChanged: (i) => selectedHour = hours[i],
                                  children: hours
                                      .map((h) => Text("$h시", style: GoogleFonts.jua(fontSize: 18)))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              scheduleExpiryNotification(item);
                            },
                            child: Text("확인"),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )),
          if (notificationSummaries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.indigo),
                      SizedBox(width: 10),
                      Text("알림 설정 내역", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  ...notificationSummaries.map((s) => Text(s)),
                ],
              ),
            )
        ],
      ),
    );
  }
}
