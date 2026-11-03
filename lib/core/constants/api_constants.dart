import 'package:flutter/foundation.dart';

class ApiConstants {
  // Jika di Web / Chrome, otomatis gunakan localhost (127.0.0.1)
  // Jika di Android (HP Fisik), gunakan IP Wi-Fi PC (192.168.18.4)
  // Jika di Android Emulator bawaan, ganti ke 'http://10.0.2.2:8000/api'
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://192.168.18.4:8000/api';
  }

  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String modules = '/modules';
  static const String quizzes = '/quizzes';
  static const String studentDashboard = '/student/dashboard';
  static const String adminDashboard = '/admin/dashboard';
  static const String teachers = '/teachers';
  static const String students = '/students';

  /// Memformat URL gambar atau media agar selalu dapat diakses dari Web maupun HP fisik Android
  static String? resolveMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      if (kIsWeb) return trimmed;
      try {
        final baseUri = Uri.parse(baseUrl);
        final parsed = Uri.parse(trimmed);
        if (parsed.host == 'localhost' || parsed.host == '127.0.0.1') {
          return parsed.replace(host: baseUri.host, port: baseUri.port).toString();
        }
      } catch (_) {}
      return trimmed;
    }

    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final baseUri = Uri.parse(baseUrl);
    final prefix = cleanPath.startsWith('storage/') ? cleanPath : 'storage/$cleanPath';
    return '${baseUri.scheme}://${baseUri.authority}/$prefix';
  }
}
