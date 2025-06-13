// ✅ token을 전달하지 않고 FirstPage를 단순 호출하려다 발생한 오류 수정
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

  // ✅ 실제 token 값 전달
  const String dummyToken = 'sample_token_123'; // 이후 실제 로그인 시스템 연동 필요
  const int dummyUserId = 1;

  runApp(
    ChangeNotifierProvider(
      create: (_) => GifticonState(),
      child: MyApp(token: dummyToken, userId: dummyUserId),
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
  final String token;
  final int userId;

  const MyApp({super.key, required this.token, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Navigator Demo',
      home: FirstPage(token: token, userId: userId), // ✅ token 전달
      routes: {'/message': (context) => const MessagePage()},
    );
  }
}
