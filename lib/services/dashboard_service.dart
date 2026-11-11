import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/preferences_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> uploadStudentPhoto({
    required List<int> bytes,
    required String filename,
    required String? previousPhoto,
  }) async {
    final response = await ApiClient.uploadProfilePhoto(bytes, filename);
    if (response is Map && response['success'] == false) {
      throw Exception(response['message'] ?? 'Gagal mengunggah foto profil.');
    }
    final profile = await fetchStudentProfile();
    return profile;
  }

  static String normalizeHeroTheme(dynamic raw) {
    final value = raw?.toString().trim().toLowerCase();
    return value == 'galaksi' ? 'galaksi' : 'samudra';
  }

  static Future<void> _syncCachedHeroTheme(Map<String, dynamic> payload) async {
    final user = payload['user'];
    if (user is Map && user['hero_theme'] != null) {
      await PreferencesService.setHeroTheme(
        normalizeHeroTheme(user['hero_theme']),
      );
    }
  }

  static Future<Map<String, dynamic>> fetchStudentDashboard() async {
    final response = await ApiClient.get(ApiConstants.studentDashboard);
    if (response is Map &&
        response['success'] == true &&
        response['data'] != null) {
      final data = Map<String, dynamic>.from(response['data']);
      await _syncCachedHeroTheme(data);
      return data;
    }
    return {};
  }

  static Future<Map<String, dynamic>> fetchStudentProfile() async {
    final response = await ApiClient.get(ApiConstants.studentProfile);
    if (response is Map &&
        response['success'] == true &&
        response['data'] != null) {
      final data = Map<String, dynamic>.from(response['data']);
      await _syncCachedHeroTheme(data);
      return data;
    }
    return {};
  }

  static Future<Map<String, dynamic>> updateStudentProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.put(ApiConstants.studentProfile, body: data);
    if (response is Map && response['success'] == true) {
      return Map<String, dynamic>.from(response);
    }
    throw Exception(response['message'] ?? 'Gagal memperbarui profil.');
  }

  static Future<Map<String, dynamic>> updateStudentHeroTheme(
    String theme,
  ) async {
    final normalized = normalizeHeroTheme(theme);
    final response = await ApiClient.patch(
      ApiConstants.studentHeroTheme,
      body: {'hero_theme': normalized},
    );
    if (response is Map && response['success'] == true) {
      await PreferencesService.setHeroTheme(normalized);
      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : <String, dynamic>{};
      return {
        'hero_theme': normalizeHeroTheme(data['hero_theme'] ?? normalized),
        'label': data['label']?.toString() ??
            (normalized == 'galaksi' ? 'Galaksi Piksel' : 'Samudra Piksel'),
        'message': response['message']?.toString() ??
            'Tema hero berhasil diperbarui.',
      };
    }
    throw Exception(
      (response is Map ? response['message'] : null) ??
          'Gagal mengubah tema hero.',
    );
  }

  static Future<Map<String, dynamic>> fetchAdminDashboard() async {
    final response = await ApiClient.get(ApiConstants.adminDashboard);
    if (response is Map &&
        response['success'] == true &&
        response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<Map<String, dynamic>> fetchParentDashboard({int? studentId}) async {
    final query = studentId != null ? '?siswa_id=$studentId' : '';
    final response = await ApiClient.get('${ApiConstants.parentDashboard}$query');
    if (response is Map &&
        response['success'] == true &&
        response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<Map<String, dynamic>> fetchLeaderboard({int? jenjangId}) async {
    final query = (jenjangId != null && jenjangId > 0)
        ? '?jenjang=$jenjangId'
        : (jenjangId == 0 ? '?jenjang=all' : '');
    final response = await ApiClient.get('${ApiConstants.leaderboard}$query');
    if (response is Map &&
        response['success'] == true &&
        response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    final response = await ApiClient.get(ApiConstants.teachers);
    if (response is Map &&
        response['success'] == true &&
        response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchStudents({
    String? search,
  }) async {
    final query = (search != null && search.isNotEmpty)
        ? '?search=${Uri.encodeComponent(search)}'
        : '';
    final response = await ApiClient.get('${ApiConstants.students}$query');
    if (response is Map &&
        response['success'] == true &&
        response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }
}
