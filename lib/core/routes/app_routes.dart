import 'package:flutter/material.dart';

import '../../admin/profile/admin_profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String adminShell = '/admin';
  static const String adminProfile = '/admin/profile';

  static Map<String, WidgetBuilder> get routes => {
        adminProfile: (_) => const AdminProfilePage(),
      };
}
