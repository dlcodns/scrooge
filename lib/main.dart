import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gifticon_state.dart';
import 'pushalarm_message.dart';
import 'firstpage.dart';
import 'notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Navigator Demo',
      home: const FirstPage(),
      routes: {'/message': (context) => const MessagePage()},
    );
  }
}
