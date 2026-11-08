import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

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
