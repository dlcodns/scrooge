import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'group.dart';

class GroupCreateStep1 extends StatefulWidget {
  const GroupCreateStep1({super.key});

  @override
  State<GroupCreateStep1> createState() => _GroupCreateStep1State();
}

class _GroupCreateStep1State extends State<GroupCreateStep1> {
  List<String> selectedFriends = [];
  final List<String> friends = ["송영은", "박형우", "이채운", "홍길동", "이무진"];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<String> filteredFriends = friends
        .where((friend) => friend.contains(searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          '친구 선택',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.search, size: 24),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupCreateStep2(selectedFriends: selectedFriends),
            ),
          );
        },
        backgroundColor: const Color(0xFF7081F1),
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class GroupCreateStep2 extends StatefulWidget {
  final List<String> selectedFriends;

  const GroupCreateStep2({super.key, required this.selectedFriends});

  @override
  State<GroupCreateStep2> createState() => _GroupCreateStep2State();
}

class _GroupCreateStep2State extends State<GroupCreateStep2> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
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
            const SizedBox(height: 32),
            const Text(
              '갤러리 사진을 첨부해보세요!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              '*첨부하지 않으면 기본이미지로 설정됩니다',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100)
                  : const Icon(Icons.image_outlined, size: 64),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 여기서 저장된 방 이름과 사진 정보를 활용하여 Group으로 이동
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Group()),
            (route) => false,
          );
        },
        backgroundColor: const Color(0xFF7081F1),
        child: const Icon(Icons.check),
      ),
    );
  }
}
