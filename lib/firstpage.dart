import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signup_complete_screen.dart';
import 'screens/preference_screen.dart';
import 'screens/friend_add_success_screen.dart';
import 'screens/add_friend_screen.dart';
import 'screens/friend_profile_screen.dart';
import 'screens/main_tab_screen.dart';
import 'screens/notification_screen.dart'; // 알림
import 'signup_in_screen.dart';
import 'screens/friend_list_screen.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알뜰티콘',
      theme: ThemeData(
        primaryColor: const Color(0xFF577BE5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF577BE5),
          ),
        ),
      ),
      initialRoute: '/', // 시작은 로그인
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SignupInScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());

          case '/signup_complete':
            final nickname = settings.arguments as String? ?? '사용자';
            return MaterialPageRoute(
              builder: (_) => SignupCompleteScreen(nickname: nickname),
            );

          case '/preference':
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final nickname = args['nickname'] as String? ?? '사용자';
              return MaterialPageRoute(
                builder: (_) => PreferenceScreen(),
              );
            }

          case '/friend_list':
            return MaterialPageRoute(
              builder: (_) => const FriendListScreen(),
            );

          case '/friend_add_success':
            final args = settings.arguments as Map<String, dynamic>;
            final name = args['friendName'] as String;
            return MaterialPageRoute(
              builder: (_) => FriendAddSuccessScreen(friendName: name),
            );

          case '/friend_add':
            return MaterialPageRoute(
              builder: (_) => const FriendAddScreen(),
            );

          case '/friend_profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => FriendProfileScreen(userId: args['userId']),
            );


          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            );

          case '/main':
            return MaterialPageRoute(
              builder: (_) => const MainTabScreen(),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404 - 페이지를 찾을 수 없습니다')),
              ),
            );
        }
      },
    );
  }
}
