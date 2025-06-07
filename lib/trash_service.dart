import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trash_item.dart';

Future<List<TrashItem>> fetchTrashList() async {
  const String baseUrl = 'http://YOUR_BACKEND_URL'; // 실제 백엔드 URL로 교체
  final url = Uri.parse('$baseUrl/api/mypage/trash/me');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer your_token', // 필요 없다면 주석 처리 또는 삭제
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => TrashItem.fromJson(json)).toList();
  } else {
    throw Exception('휴지통 데이터를 불러오지 못했습니다: ${response.statusCode}');
  }
}
