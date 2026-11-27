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
      authenticated: false,
    );

    final data = response;

    if (data['success'] == true) {
      final token = data['token'];
      final user = data['user'];
      if (token is! String || token.isEmpty || user is! Map) {
        throw Exception('Respons login tidak lengkap.');
      }
      await _saveUser(user);
      await SecureStorage.setToken(token);

      return data;
    }

    throw Exception(data['message'] ?? 'Login gagal.');
  }

  static Future<void> _saveUser(Map user) async {
    await SecureStorage.write('user_id', user['id_user']?.toString() ?? '');
    await SecureStorage.write('user_name', user['nama']?.toString() ?? '');
    await SecureStorage.write('user_email', user['email']?.toString() ?? '');
    await SecureStorage.write(
      'user_role',
      user['id_tipeuser']?.toString() ?? '',
    );
    await SecureStorage.write(
      'user_jenjang',
      user['id_jenjang']?.toString() ?? '',
    );
  }

  static Future<String?> restoreRole() async {
    if (!await isLoggedIn()) return null;
    try {
      final response = await ApiClient.get(ApiConstants.me);
      if (response is Map &&
          response['success'] == true &&
          response['user'] is Map) {
        await _saveUser(response['user'] as Map);
      }
    } on ApiResponseException catch (error) {
      if (error.invalidSession) return null;
      if (error.statusCode == 403) rethrow;
    } catch (_) {
      // Use the cached profile when the server is temporarily unreachable.
    }
    return getRole();
  }

  static Future<String?> getToken() async {
    return SecureStorage.getToken();
  }

  static Future<String?> getRole() async {
    return SecureStorage.read('user_role');
  }

  static Future<String?> getJenjang() async {
    return SecureStorage.read('user_jenjang');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, String?>> getSavedUser() async {
    return {
      'id': await SecureStorage.read('user_id'),
      'name': await SecureStorage.read('user_name'),
      'email': await SecureStorage.read('user_email'),
      'role': await SecureStorage.read('user_role'),
      'jenjang': await SecureStorage.read('user_jenjang'),
    };
  }

  static Future<void> logout() async {
    final rememberMe = await SecureStorage.read('remember_me');
    final savedEmail = await SecureStorage.read('saved_email');
    final savedPassword = await SecureStorage.read('saved_password');

    try {
      await ApiClient.post(ApiConstants.logout);
    } catch (_) {
      // Tetap hapus session lokal jika gagal menghubungi server
    }
    await SecureStorage.deleteAll();

    if (rememberMe == 'true') {
      await SecureStorage.write('remember_me', 'true');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        await SecureStorage.write('saved_email', savedEmail);
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        await SecureStorage.write('saved_password', savedPassword);
      }
    }
  }
}
