import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pushalarm_message.dart';
import 'firstpage.dart'; // 시작화면
import 'notification.dart';

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로컬 푸시 알림 초기화
  await initializeNotification();

  // 앱이 종료된 상태에서 알림 클릭 시 처리
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed(
        '/message',
        arguments: notificationAppLaunchDetails?.notificationResponse?.payload,
      );
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Navigator Demo',
      home: const FirstPage(), // 시작 화면 유지
      routes: {
        '/message': (context) => const MessagePage(),
      },
    );
  }
}
