import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendProfileScreen extends StatefulWidget {
  const FriendProfileScreen({super.key});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late bool _isFavorite;
  String nickname = '';
  String first = '';
  String second = '';
  String third = '';
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    _isFavorite = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      userId = args?['userId'];
      fetchFriendPreference();
    });
  }

  Future<void> fetchFriendPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';

    if (userId == null) return;

    print("📥 친구 프로필 요청 ID: $userId");
    final response = await http.get(
      Uri.parse('http://172.30.1.18:8080/api/preferences/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("📡 응답 코드: ${response.statusCode}");
    print("📡 응답 내용: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        nickname = json['nickname'] ?? '';
        first = json['first'] ?? '';
        second = json['second'] ?? '';
        third = json['third'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구 정보를 불러오지 못했습니다.')),
      );
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('친구 삭제'),
        content: const Text('정말로 이 친구를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('친구가 삭제되었습니다.')),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('친구 삭제'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$nickname 님은 $first 을(를) 제일 좋아해요!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (second.isNotEmpty) Text('2순위  $second'),
                    if (third.isNotEmpty) Text('3순위  $third'),
                  ],
                ),
              ),
            ),
    );
  }
}
