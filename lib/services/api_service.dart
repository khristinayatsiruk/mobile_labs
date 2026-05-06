import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = 'http://192.168.0.106:5002/api';

  static Future<List<dynamic>> getTips() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse('$baseUrl/tips'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

        await prefs.setString('cached_tips', response.body);

        debugPrint('Дані успішно отримано з сервера: ${data.length} шт.');
        return data;
      } else {
        debugPrint('Помилка сервера: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Помилка підключення до API: $e');
    }

    final String? cached = prefs.getString('cached_tips');
    if (cached != null) {
      debugPrint('Використовуємо закешовані поради');
      return jsonDecode(cached) as List<dynamic>;
    }

    return [];
  }
}
