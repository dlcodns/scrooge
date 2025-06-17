import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'group.dart';

class GroupCreateStep1 extends StatefulWidget {
  const GroupCreateStep1({super.key});

  @override
  State<GroupCreateStep1> createState() => _GroupCreateStep1State();
}


class _GroupCreateStep1State extends State<GroupCreateStep1> {
  List<String> selectedFriends = [];
  final List<String> friends = ["송영은", "박형우", "이채운", "홍길동", "이무진", "하하"];
  final Map<String, String> nameToUserId = {
    "송영은": "young123",
    "박형우": "hwoung123",
    "이채운": "chaeun123",
    "홍길동": "hong123",
    "이무진": "moojin123",
    "하하": "haha123",
  };
  String searchQuery = "";
  final TextEditingController _nameController = TextEditingController();

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름을 입력해주세요.')),
      );
      return;
    }

    if (selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구를 한 명 이상 선택해주세요.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final memberIds = selectedFriends
        .map((name) => nameToUserId[name])
        .where((id) => id != null)
        .toList();

    final body = jsonEncode({
      "roomName": _nameController.text,
      "memberIds": memberIds,
    });

    final url = Uri.parse('http://172.30.1.54:8080/api/group/create');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const Group(showToastMessage: true),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('생성 실패: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredFriends = friends
        .where((friend) => friend.contains(searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          '갤러리 설정',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '갤러리 이름을 입력하세요',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '친구 선택',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '친구 검색',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black54, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (searchQuery.isNotEmpty)
              ...filteredFriends.map((friend) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      friend,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    value: selectedFriends.contains(friend),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedFriends.add(friend);
                        } else {
                          selectedFriends.remove(friend);
                        }
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        backgroundColor: const Color(0xFF7081F1),
        child: const Icon(Icons.check),
      ),
    );
  }
}