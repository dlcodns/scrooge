import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<int> scheduleNotification(
    String content, DateTime expiryDate, int daysBefore) async {
  final DateTime targetDate = expiryDate.subtract(Duration(days: daysBefore));
  final DateTime notificationDateTime = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
    9, // 오전 9시
  );

  // 과거 시간은 예약하지 않음
  if (notificationDateTime.isBefore(DateTime.now())) {
    print("⛔ 알림 시간이 과거입니다: $notificationDateTime");
    return -1;
  }

  final int id =
      '${content}_${notificationDateTime.toIso8601String()}'.hashCode;

  await flutterLocalNotificationsPlugin.zonedSchedule(
  id,
  '유효기간 알림',
  content,
  tz.TZDateTime.from(notificationDateTime, tz.local),
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'expiry_channel',
      'Expiry Alerts',
      channelDescription: '유효기간 알림을 위한 채널',
      importance: Importance.max,
      priority: Priority.high,
    ),
  ),
  androidScheduleMode: AndroidScheduleMode.inexact, // ← 여기 수정
  matchDateTimeComponents: DateTimeComponents.dateAndTime,
);


  return id;
}

Future<void> cancelNotification(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

Future<List<String>> loadSavedSummaries() async {
  return [];
}

Future<List<int>> loadSavedNotificationIds() async {
  return [];
}

Future<void> saveNotifications(List<String> summaries, List<int> ids) async {
  // 초기화 버전에서는 저장 생략
}
