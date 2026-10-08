
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/storage/secure_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    final data = response;

    if (data['success'] == true) {
      final token = data['token'];
      if (token != null) {
        await SecureStorage.setToken(token.toString());
      }

      final user = data['user'];
      if (user != null) {
        await SecureStorage.write('user_id', user['id_user']?.toString() ?? '');
        await SecureStorage.write('user_name', user['nama']?.toString() ?? '');
        await SecureStorage.write('user_email', user['email']?.toString() ?? '');
        await SecureStorage.write('user_role', user['id_tipeuser']?.toString() ?? '');
      }

      return data;
    }

    throw Exception(data['message'] ?? 'Login gagal.');
  }

  static Future<String?> getToken() async {
    return SecureStorage.getToken();
  }

  static Future<String?> getRole() async {
    return SecureStorage.read('user_role');
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post(ApiConstants.logout);
    } catch (_) {
      // Tetap hapus session lokal
    }
    await SecureStorage.deleteAll();
  }
}
