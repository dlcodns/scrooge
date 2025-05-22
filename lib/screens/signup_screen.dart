// signup_screen.dart - 비밀번호 정규식 이중이스케이프 수정
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원가입', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                      Navigator.pushNamed(context, '/signup_complete');
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
