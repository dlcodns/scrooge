import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _obscure = true;

  Future<Map<String, String>?> login(String username, String password) async {
    final url = Uri.parse('http://172.30.129.19:8080/api/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final nickname = data['nickname'];
        final id = data['id'];

        if (token != null && id != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', token);
          await prefs.setString('nickname', nickname ?? '');
          await prefs.setInt('userId', id);

          return {
            'token': token,
            'nickname': nickname ?? '',
            'id': id.toString(),
          };
        }
      }

      print("로그인 실패: ${response.statusCode} / ${response.body}");
      return null;
    } catch (e) {
      print("로그인 중 오류 발생: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: '아이디를 입력해주세요'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: '비밀번호를 입력해주세요',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final username = _idController.text.trim();
                  final password = _pwController.text.trim();

                  if (username.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해주세요')),
                    );
                    return;
                  }

                  final result = await login(username, password);

                  if (result != null) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/preference',
                      arguments: {
                        'nickname': result['nickname'],
                        'token': result['token'],
                        'userId': int.parse(result['id']!),
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF577BE5),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text('회원가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
