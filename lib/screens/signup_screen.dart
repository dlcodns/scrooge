// signup_screen.dart - 비밀번호 정규식 이중이스케이프 수정
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nicknameController = TextEditingController();
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _emailController = TextEditingController();

  bool _pwObscure = true;
  bool _confirmPwObscure = true;

  final _formKey = GlobalKey<FormState>();

  bool _isIdChecked = false;
  bool _isIdDuplicated = false;

  void checkIdDuplication() {
    final id = _idController.text.trim();
    setState(() {
      _isIdDuplicated = (id == 'test123');
      _isIdChecked = true;
    });
    _formKey.currentState?.validate();
  }

  Future<void> signupUser() async {
    final url = Uri.parse(
      'http://172.30.129.19:8080/api/users/signup',
    ); // 예: http://10.0.2.2:8080/api/users/signup

    final body = jsonEncode({
      "userId": _idController.text.trim(),
      "password": _pwController.text.trim(),
      "nickname": _nicknameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": "01012345678", // UI에 없으니 일단 더미로
      "region": "서울", // UI에 없으니 일단 더미로
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        print('회원가입 성공: ${resData["message"]}');
        if (!mounted) return;
        Navigator.pushNamed(context, '/signup_complete');
      } else {
        final resData = jsonDecode(response.body);
        showSnackBar(context, resData["message"] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      showSnackBar(context, '에러 발생: $e');
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '회원가입',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nicknameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: '닉네임을 입력해주세요'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length > 6) {
                    return '문자 6자 이내로 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _idController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: '아이디를 입력해주세요',
                      ),
                      validator: (value) {
                        if (!_isIdChecked) {
                          return 'ID 중복 확인을 해주세요';
                        }
                        if (value == null ||
                            !RegExp(r'^[a-z0-9]{6,12}$').hasMatch(value)) {
                          return '영소문자와 숫자로 6~12자 입력해주세요';
                        }
                        if (_isIdDuplicated) {
                          return '이미 존재하는 아이디입니다';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: checkIdDuplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF577BE5),
                    ),
                    child: const Text(
                      '중복 확인',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pwController,
                obscureText: _pwObscure,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: '비밀번호를 입력해주세요',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _pwObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _pwObscure = !_pwObscure),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(
                        r"""^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*()_\-=\[\]{}|:;"'<>,.?/~`]).{8,20}$""",
                      ).hasMatch(value)) {
                    return '영문 대소문자, 숫자, 특수문자 포함 8~20자 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pwConfirmController,
                obscureText: _confirmPwObscure,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: '비밀번호를 한 번 더 입력해주세요',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPwObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => _confirmPwObscure = !_confirmPwObscure,
                        ),
                  ),
                ),
                validator: (value) {
                  if (value != _pwController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: '이메일을 입력해주세요'),
                validator: (value) {
                  if (value == null ||
                      !RegExp(
                        r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                      ).hasMatch(value)) {
                    return '올바른 이메일 형식이 아닙니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      signupUser(); // ← 우리가 만든 API 호출 함수!
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF577BE5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
