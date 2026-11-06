import 'package:flutter/foundation.dart';

class ApiConstants {
  // Jika di Web / Chrome, otomatis gunakan localhost (127.0.0.1)
  // Jika di Android (HP Fisik), gunakan IP Wi-Fi PC (192.168.18.4)
  // Jika di Android Emulator bawaan, ganti ke 'http://10.0.2.2:8000/api'
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://paging-defy-bluish.ngrok-free.dev/api';
    }
    return 'https://paging-defy-bluish.ngrok-free.dev/api';
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

    try {
      final baseUri = Uri.parse(baseUrl);

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        final parsed = Uri.parse(trimmed);
        final isLocalHost = parsed.host == 'localhost' ||
            parsed.host == '127.0.0.1' ||
            parsed.host.endsWith('.test') ||
            parsed.host.startsWith('192.168.') ||
            parsed.host.startsWith('10.0.');

        if (isLocalHost) {
          return parsed
              .replace(
                scheme: baseUri.scheme,
                host: baseUri.host,
                port: baseUri.hasPort ? baseUri.port : null,
              )
              .toString();
        }
        return trimmed;
      }

      final cleanPath =
          trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
      final prefix = cleanPath.startsWith('storage/')
          ? cleanPath
          : 'storage/$cleanPath';
      final portPart = baseUri.hasPort ? ':${baseUri.port}' : '';
      return '${baseUri.scheme}://${baseUri.host}$portPart/$prefix';
    } catch (_) {
      return trimmed;
    }
  }
}
