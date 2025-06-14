import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GifticonSelectPage extends StatefulWidget {
  final int groupId;

  const GifticonSelectPage({super.key, required this.groupId});

  @override
  State<GifticonSelectPage> createState() => _GifticonSelectPageState();
}

class _GifticonSelectPageState extends State<GifticonSelectPage> {
  List<Map<String, dynamic>> myGifticons = [];
  Set<String> selectedGifticonNumbers = {};

  @override
  void initState() {
    super.initState();
    fetchMyGifticons();
  }

  Future<void> fetchMyGifticons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    print("accessToken: $token");

    final response = await http.get(
      Uri.parse('http://192.168.26.252:8080/api/group/my-gifticons'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        myGifticons = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load gifticons');
    }
  }

  Future<void> uploadSelectedGifticons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final response = await http.post(
      Uri.parse('http://192.168.26.252:8080/api/group/add-gifticons'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'groupId': widget.groupId,
        'gifticonNumbers': selectedGifticonNumbers.toList(),
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // 성공 시 이전 페이지에 true 전달
    } else {
      print('등록 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('내 기프티콘 선택'),
      ),
      body: ListView.builder(
        itemCount: myGifticons.length,
        itemBuilder: (context, index) {
          final gifticon = myGifticons[index];
          final number = gifticon['gifticonNumber'];
          final brand = gifticon['brand'];
          final dueDate = gifticon['dueDate'];

          final isSelected = selectedGifticonNumbers.contains(number);

          return ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked!) {
                    selectedGifticonNumbers.add(number);
                  } else {
                    selectedGifticonNumbers.remove(number);
                  }
                });
              },
            ),
            title: Text('$brand - $number'),
            subtitle: Text('유효기간: $dueDate'),
          );
        },
      ),

      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: selectedGifticonNumbers.isEmpty ? null : uploadSelectedGifticons,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF577BE5),
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            '업로드',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

}
