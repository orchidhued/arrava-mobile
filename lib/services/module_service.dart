import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/module.dart';
import 'auth_service.dart';

class ModuleService {
  static const String baseUrl = 'http://192.168.18.233/api';

  static Future<List<Module>> getModules() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/modules'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List modules = data['data'] ?? [];

      return modules.map((item) => Module.fromJson(item)).toList();
    }

    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
}
