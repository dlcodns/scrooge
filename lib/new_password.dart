import 'package:flutter/material.dart';
import 'mypage.dart';
import 'dart:async';

class SetNewPasswordScreen extends StatefulWidget {
  final String token; 
  const SetNewPasswordScreen({required this.token, Key? key}) : super(key: key);

  @override
  _SetNewPasswordScreenState createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool isMismatch = false;
  bool isPasswordValid = true;

  final RegExp passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\\$&*~]).{8,20}\$');

  bool get isFormValid =>
      newPasswordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty &&
      newPasswordController.text == confirmPasswordController.text &&
      passwordRegex.hasMatch(newPasswordController.text);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("비밀번호 변경",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.05)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06, vertical: screenHeight * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: obscureNewPassword,
              decoration: InputDecoration(
                hintText: "새로운 비밀번호를 입력해주세요",
                helperText: "영문, 숫자, 특수문자 포함 8자 이상 20자 이내로 입력하세요.",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(obscureNewPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscureNewPassword = !obscureNewPassword;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  isPasswordValid = passwordRegex.hasMatch(value);
                  isMismatch = newPasswordController.text != confirmPasswordController.text;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: "새로운 비밀번호를 한 번 더 입력해주세요",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {
                      isMismatch = newPasswordController.text != confirmPasswordController.text;
                    });
                  },
                ),
                if (isMismatch)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 8.0),
                    child: Text(
                      "일치하지 않습니다.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: screenWidth * 0.015,
                      ),
                    ),
                  ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                ElevatedButton(
                  onPressed: isFormValid
                      ? () {
                          setState(() {
                            isMismatch = false;
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordChangedScreen(token: widget.token),
                            ),
                          );
                        }
                      : null,
                  child: Text("변경하기",
                      style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormValid ? Colors.indigo[400] : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                    minimumSize: Size(double.infinity, 0),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("돌아가기",
                      style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[400],
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                    minimumSize: Size(double.infinity, 0),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PasswordChangedScreen extends StatefulWidget {
  final String token; // ✅ 추가
  const PasswordChangedScreen({required this.token, Key? key}) : super(key: key);

  @override
  _PasswordChangedScreenState createState() => _PasswordChangedScreenState();
}

class _PasswordChangedScreenState extends State<PasswordChangedScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyPageScreen(token: widget.token),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "비밀번호가 변경되었습니다.",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "로그인페이지로 이동합니다.",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
