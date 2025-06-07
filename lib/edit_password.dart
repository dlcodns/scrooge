import 'package:flutter/material.dart';
import 'new_password.dart';

class EditPasswordScreen extends StatefulWidget {
  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;
  bool isPasswordWrong = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          '비밀번호 변경',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06, vertical: screenHeight * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: "현재 비밀번호를 입력해주세요",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  isPasswordWrong = false;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.01),
            if (isPasswordWrong)
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 8.0),
                child: Text(
                  "잘못된 비밀번호 입니다.",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: screenWidth * 0.025,
                  ),
                ),
              ),
            Spacer(),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text != "1234") {
                      setState(() {
                        isPasswordWrong = true;
                      });
                    } else {
                      setState(() {
                        isPasswordWrong = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetNewPasswordScreen()),
                      );
                    }
                  },
                  child:
                      Text("변경하기", style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[400],
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                    minimumSize: Size(double.infinity, 0),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text("돌아가기", style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[400],
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.018),
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