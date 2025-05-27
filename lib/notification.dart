import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    9,
  );

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
    androidScheduleMode: AndroidScheduleMode.inexact,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );

  // 저장
  List<String> summaries = await loadSavedSummaries();
  List<int> ids = await loadSavedNotificationIds();
  summaries.add(content);
  ids.add(id);

  print('✅ 저장할 알림 내용: $summaries');
  print('✅ 저장할 알림 ID들: $ids');

  await saveNotifications(summaries, ids);

  return id;
}

Future<void> cancelNotification(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);

  List<String> summaries = await loadSavedSummaries();
  List<int> ids = await loadSavedNotificationIds();

  int index = ids.indexOf(id);
  if (index != -1) {
    summaries.removeAt(index);
    ids.removeAt(index);
    await saveNotifications(summaries, ids);
    print('🗑️ 알림 취소됨. 저장된 내역 갱신됨.');
  }
}

Future<List<String>> loadSavedSummaries() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('notification_summaries');
  if (jsonString != null) {
    print('📦 불러온 알림 내용: $jsonString');
    return List<String>.from(json.decode(jsonString));
  }
  return [];
}

Future<List<int>> loadSavedNotificationIds() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('notification_ids');
  if (jsonString != null) {
    print('📦 불러온 알림 ID들: $jsonString');
    return List<int>.from(json.decode(jsonString));
  }
  return [];
}

Future<void> saveNotifications(List<String> summaries, List<int> ids) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('notification_summaries', json.encode(summaries));
  await prefs.setString('notification_ids', json.encode(ids));
  print('✅ SharedPreferences에 알림 저장 완료');
}
