import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class DashboardService {
  static Future<Map<String, dynamic>> fetchStudentDashboard() async {
    final response = await ApiClient.get(ApiConstants.studentDashboard);
    if (response is Map && response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<Map<String, dynamic>> fetchAdminDashboard() async {
    final response = await ApiClient.get(ApiConstants.adminDashboard);
    if (response is Map && response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    final response = await ApiClient.get(ApiConstants.teachers);
    if (response is Map && response['success'] == true && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchStudents({String? search}) async {
    final query = (search != null && search.isNotEmpty) ? '?search=${Uri.encodeComponent(search)}' : '';
    final response = await ApiClient.get('${ApiConstants.students}$query');
    if (response is Map && response['success'] == true && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }
}

