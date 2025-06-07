import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gifticon_state.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pushalarm_message.dart';
import 'firstpage.dart'; // 시작화면
import 'notification.dart';

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeNotification();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GifticonState(),
      child: const MyApp(),
    ),
  );

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState?.pushNamed(
        '/message',
        arguments: notificationAppLaunchDetails?.notificationResponse?.payload,
      );
    });
  }
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
