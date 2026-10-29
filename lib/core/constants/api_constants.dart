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
}
