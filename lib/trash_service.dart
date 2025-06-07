import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'trash_item.dart';

Future<List<TrashItem>> fetchTrashList(String token) async {
  const String baseUrl = 'http://<your-server>'; // 예: http://localhost:8080 또는 실제 서버 주소
  final url = Uri.parse('$baseUrl/api/mypage/trash/me');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => TrashItem.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    debugPrint('서버 응답: ${response.statusCode} / ${response.body}');
    throw Exception('휴지통 데이터를 불러올 수 없습니다');
  }
}
