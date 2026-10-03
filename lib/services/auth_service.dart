import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Android Emulator
  static const String baseUrl = 'http://192.168.1.3/api';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['token'];

      if (token != null) {
        await _storage.write(key: 'auth_token', value: token.toString());
      }

      final user = data['user'];

      if (user != null) {
        await _storage.write(
          key: 'user_id',
          value: user['id_user']?.toString(),
        );

        await _storage.write(key: 'user_name', value: user['nama']?.toString());

        await _storage.write(
          key: 'user_email',
          value: user['email']?.toString(),
        );

        await _storage.write(
          key: 'user_role',
          value: user['id_tipeuser']?.toString(),
        );
      }

      return data;
    }

    throw Exception(data['message'] ?? 'Login gagal.');
  }

  static Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  static Future<String?> getRole() async {
    return _storage.read(key: 'user_role');
  }

  static Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {
        // Tetap hapus session lokal
      }
    }

    await _storage.deleteAll();
  }
}
