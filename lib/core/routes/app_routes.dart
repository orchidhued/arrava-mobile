import 'package:flutter/material.dart';

import '../../admin/admin_shell.dart';
import '../../admin/profile/admin_profile_page.dart';
import '../../admin/quizzes/manage_quiz_page.dart';
import '../../auth/login.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/quizzes/student_quiz_list_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String adminShell = '/admin';
  static const String adminProfile = '/admin/profile';
  static const String manageQuizzes = '/admin/quizzes';
  static const String studentQuizzes = '/student/quizzes';
  static const String quizzes = '/quizzes';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        adminProfile: (_) => const AdminProfilePage(),
        dashboard: (_) => const DashboardScreen(),
        adminShell: (_) => const AdminShell(),
        manageQuizzes: (_) => const ManageQuizPage(),
        studentQuizzes: (_) => const StudentQuizListPage(),
        quizzes: (_) => const ManageQuizPage(),
      };
}
