import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'trash_item.dart';

Future<List<TrashItem>> fetchTrashList() async {
  print("📡 API 요청 시작: http://192.168.26.252:8080/api/mypage/trash/me");

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';
    print("🪪 불러온 토큰: $token");

    final response = await http.get(
      Uri.parse('http://192.168.26.252:8080/api/mypage/trash/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("✅ 응답 코드: ${response.statusCode}");
    print("📦 응답 바디: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TrashItem.fromJson(json)).toList();
    } else {
      throw Exception('휴지통 정보를 불러오는데 실패했습니다: ${response.body}');
    }
  } catch (e) {
    print("❌ 네트워크 예외 발생: $e");
    throw Exception('네트워크 오류 발생: $e');
  }
}
