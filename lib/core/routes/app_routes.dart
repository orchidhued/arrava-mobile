import 'package:flutter/material.dart';

import '../../admin/profile/admin_profile_page.dart';
import '../../auth/login.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String adminShell = '/admin';
  static const String adminProfile = '/admin/profile';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        adminProfile: (_) => const AdminProfilePage(),
      };
}
