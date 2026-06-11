import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Map<String, dynamic>>> fetchServiceTips() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/posts?_limit=5'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load tips');
      }
    } catch (e) {
      throw Exception('Network error: \$e');
    }
  }
}
