import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<String?> notificationStream =
    StreamController<String?>.broadcast();

Future<void> initializeNotification() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      print('🔔 알림 클릭됨, payload: $payload');
      notificationStream.add(payload);
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  final payload = response.payload;
  print('🔙 (백그라운드) 알림 클릭됨: $payload');
  notificationStream.add(payload);
}

Future<int> scheduleNotification(
    String content, DateTime expiryDate, int daysBefore) async {
  DateTime targetDate = expiryDate.subtract(Duration(days: daysBefore));
  DateTime notificationDateTime = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
    9,
  );

  // ✅ 오늘이 targetDate면 → 테스트용 20초 후 알림으로 덮어쓰기
  final now = DateTime.now();
  final isSameDate = now.year == targetDate.year &&
      now.month == targetDate.month &&
      now.day == targetDate.day;

  if (isSameDate) {
    notificationDateTime = now.add(Duration(seconds: 20));
    print("🧪 [오늘이 알림 대상일] → 20초 후 알림 예약: $notificationDateTime");
  }

  if (notificationDateTime.isBefore(now)) {
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

  List<String> summaries = await loadSavedSummaries();
  List<int> ids = await loadSavedNotificationIds();

  if (!ids.contains(id)) {
    summaries.add(content);
    ids.add(id);
    print('✅ 저장할 알림 내용: $summaries');
    print('✅ 저장할 알림 ID들: $ids');
    await saveNotifications(summaries, ids);
  } else {
    print('⚠️ 이미 등록된 알림 ID. 중복 저장 생략됨.');
  }

  return id;
}


// ✅ 10초 후 테스트용 알림
Future<void> scheduleTestNotificationIn10Seconds() async {
  final DateTime now = DateTime.now();
  final DateTime notificationDateTime = now.add(Duration(seconds: 10));
  final int id = 'test_${notificationDateTime.toIso8601String()}'.hashCode;

  print('💡 예약 시도: $notificationDateTime');

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    '🧪 테스트 알림 (10초 후)',
    '이 알림은 지금으로부터 10초 후에 울립니다.',
    tz.TZDateTime.from(notificationDateTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: '테스트용 푸시 알림',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexact,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );

  print("✅ [10초 후] 테스트 알림 예약 완료: ${notificationDateTime.toLocal()}");
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

Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
  await saveNotifications([], []);
  print('🧹 모든 알림 취소 및 저장 내역 초기화 완료');
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

Future<void> clearAllNotificationPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('notification_summaries');
  await prefs.remove('notification_ids');
  print("🧹 SharedPreferences 초기화 완료");
}
