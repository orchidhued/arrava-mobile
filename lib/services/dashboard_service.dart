import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class DashboardService {
  static Future<Map<String, dynamic>> uploadStudentPhoto({
    required List<int> bytes,
    required String filename,
    required String? previousPhoto,
  }) async {
    await ApiClient.uploadProfilePhoto(bytes, filename);
    final profile = await fetchStudentProfile();
    final user = profile['user'] as Map?;
    final photo = user?['foto_profil']?.toString();
    // The current API may return success while ignoring an unknown file field.
    // Only report success after a fresh profile confirms the saved photo.
    if (photo == null || photo.isEmpty || photo == previousPhoto) {
      throw Exception(
        'Foto belum tersimpan. Upload foto dari aplikasi belum tersedia. '
        'Untuk sementara, ganti foto melalui website ARRAVA.',
      );
    }
    return profile;
  }

  static Future<Map<String, dynamic>> fetchStudentDashboard() async {
    final response = await ApiClient.get(ApiConstants.studentDashboard);
    if (response is Map &&
        response['success'] == true &&
        response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<Map<String, dynamic>> fetchStudentProfile() async {
    final response = await ApiClient.get('/student/profile');
    if (response is Map &&
        response['success'] == true &&
        response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<Map<String, dynamic>> updateStudentProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.put('/student/profile', body: data);
    if (response is Map && response['success'] == true) {
      return Map<String, dynamic>.from(response);
    }
    throw Exception(response['message'] ?? 'Gagal memperbarui profil.');
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
