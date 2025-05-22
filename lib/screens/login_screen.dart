import 'package:flutter/material.dart';
import 'package:scrooge/group.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 배경 흰색
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '알뜰티콘',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
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
            ElevatedButton(
              onPressed: () {
                if (_idController.text == 'test123' &&
                    _pwController.text == 'Asdfhjkl123!') {
                  // ⭐ 여기서 group.dart로 이동!
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Group(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('아이디 또는 비밀번호가 잘못되었습니다')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF577BE5),
              ),
              child: const Text('로그인', style: TextStyle(color: Colors.white)),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('ID 찾기'),
                ),
                const Text('|'),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('PW 찾기'),
                ),
                const Text('|'),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
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
