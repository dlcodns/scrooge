import 'package:flutter/material.dart';

class FriendAddSuccessScreen extends StatefulWidget {
  final String friendName;
  final String token;
  final int userId;

  const FriendAddSuccessScreen({
    super.key,
    required this.friendName,
    required this.token,
    required this.userId,
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

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(
        context,
        '/friend_list',
        arguments: {'token': widget.token, 'userId': widget.userId},
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
