import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class AttendanceService {
  static Future<List<Map<String, dynamic>>> fetchActiveSessions() async {
    final response = await ApiClient.get(ApiConstants.activeAttendanceSessions);
    if (response is Map &&
        response['success'] == true &&
        response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    throw Exception(
      response is Map && response['message'] != null
          ? response['message'].toString()
          : 'Format daftar sesi presensi dari server tidak valid.',
    );
  }

  static Future<Map<String, dynamic>> scanStudent({
    required int sessionId,
    required String token,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.attendanceScan(sessionId),
      body: {'token': token},
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Format hasil scan dari server tidak valid.');
  }

  static Future<Map<String, dynamic>> fetchSessionRecap(int sessionId) async {
    final response = await ApiClient.get(
      ApiConstants.attendanceRecap(sessionId),
    );
    if (response is Map &&
        response['success'] == true &&
        response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }

    throw Exception(
      response is Map && response['message'] != null
          ? response['message'].toString()
          : 'Format rekap presensi dari server tidak valid.',
    );
  }
}
