import 'package:flutter/material.dart';
import 'preference_screen.dart';

class SignupCompleteScreen extends StatefulWidget {
  final String nickname;

  const SignupCompleteScreen({super.key, required this.nickname});

  @override
  State<SignupCompleteScreen> createState() => _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends State<SignupCompleteScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(
        context,
        '/preference',
        arguments: widget.nickname,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '회원가입이 완료되었습니다.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
