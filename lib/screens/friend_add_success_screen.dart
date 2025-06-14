import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendAddSuccessScreen extends StatefulWidget {
  final String friendName;

  const FriendAddSuccessScreen({
    super.key,
    required this.friendName,
  });

  @override
  State<FriendAddSuccessScreen> createState() => _FriendAddSuccessScreenState();
}

class _FriendAddSuccessScreenState extends State<FriendAddSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    Future.delayed(const Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken') ?? '';
      final userId = prefs.getInt('userId') ?? -1;

      Navigator.pushReplacementNamed(
        context,
        '/friend_list',
        arguments: {'token': token, 'userId': userId},
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.friendName}님께\n친구 요청을 보냈습니다!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
