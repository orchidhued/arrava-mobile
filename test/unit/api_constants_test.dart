import 'package:flutter_test/flutter_test.dart';
import 'package:arrava_mobile/core/constants/api_constants.dart';

void main() {
  group('ApiConstants Tests', () {
    test('Endpoint paths should be formatted correctly with leading slash', () {
      expect(ApiConstants.login, '/login');
      expect(ApiConstants.logout, '/logout');
      expect(ApiConstants.me, '/me');
      expect(ApiConstants.modules, '/modules');
      expect(ApiConstants.quizzes, '/quizzes');
      expect(ApiConstants.studentDashboard, '/student/dashboard');
      expect(ApiConstants.parentDashboard, '/parent/dashboard');
      expect(ApiConstants.leaderboard, '/leaderboard');
      expect(ApiConstants.adminDashboard, '/admin/dashboard');
      expect(ApiConstants.teachers, '/teachers');
      expect(ApiConstants.students, '/students');
    });

    test('BaseUrl should return valid URL containing /api', () {
      final url = ApiConstants.baseUrl;
      expect(url.startsWith('http://'), isTrue);
      expect(url.endsWith('/api'), isTrue);
    });
  });
}

