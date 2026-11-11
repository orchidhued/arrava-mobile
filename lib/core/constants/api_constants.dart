class ApiConstants {
  // Jika di Web / Chrome, atau di Android via USB adb reverse (adb reverse tcp:8000 tcp:8000): gunakan 127.0.0.1
  // Jika di Android via Wi-Fi langsung: gunakan IP Wi-Fi PC (192.168.18.4)
  static String get baseUrl {
    return 'http://127.0.0.1:8000/api';
    //return 'http://192.168.18.4:8000/api';
  }

  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String modules = '/modules';
  static const String quizzes = '/quizzes';
  static const String mapel = '/mapel';
  static const String studentDashboard = '/student/dashboard';
  static const String parentDashboard = '/parent/dashboard';
  static const String leaderboard = '/leaderboard';
  static const String adminDashboard = '/admin/dashboard';
  static const String teachers = '/teachers';
  static const String students = '/students';
  static const String activeAttendanceSessions = '/sesi-aktif';
  static const String notifikasiCheck = '/notifikasi/check';
  static const String notifikasiMarkRead = '/notifikasi/mark-read';

  static String attendanceRecap(int sessionId) => '/sesi/$sessionId/rekap';

  static String attendanceScan(int sessionId) => '/$sessionId/scan';

  /// Memformat URL gambar atau media agar selalu dapat diakses dari Web maupun HP fisik Android
  static String? resolveMediaUrl(String? url) {
    if (url == null ||
        url.trim().isEmpty ||
        url.trim().toLowerCase() == 'null' ||
        url.trim().toLowerCase() == 'undefined') {
      return null;
    }
    final trimmed = url.trim();

    try {
      final baseUri = Uri.parse(baseUrl);

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        final parsed = Uri.parse(trimmed);
        final isLocalHost =
            parsed.host == 'localhost' ||
            parsed.host == '127.0.0.1' ||
            parsed.host.endsWith('.test') ||
            parsed.host.startsWith('192.168.') ||
            parsed.host.startsWith('10.0.');

        if (isLocalHost) {
          String path = parsed.path;
          if (path.startsWith('/storage/')) {
            path = '/api$path';
          }
          return parsed
              .replace(
                scheme: baseUri.scheme,
                host: baseUri.host,
                port: baseUri.hasPort ? baseUri.port : null,
                path: path,
              )
              .toString();
        }
        return trimmed;
      }

      final cleanPath = trimmed.startsWith('/')
          ? trimmed.substring(1)
          : trimmed;
      final prefix = cleanPath.startsWith('api/storage/')
          ? cleanPath
          : (cleanPath.startsWith('storage/')
                ? 'api/$cleanPath'
                : 'api/storage/$cleanPath');
      final portPart = baseUri.hasPort ? ':${baseUri.port}' : '';
      return '${baseUri.scheme}://${baseUri.host}$portPart/$prefix';
    } catch (_) {
      return trimmed;
    }
  }
}
