import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'admin/admin_shell.dart';
import 'admin/modules/providers/module_provider.dart';
import 'admin/quizzes/providers/quiz_provider.dart';
import 'auth/login.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrava Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: AppRoutes.routes,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Delay singkat untuk animasi splash screen yang halus
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    try {
      final token = await AuthService.getToken();
      final role = await AuthService.getRole();

      if (!mounted) return;

      if (token != null && token.isNotEmpty && role != null) {
        final int roleId = int.tryParse(role) ?? 0;
        if (roleId == 1) {
          // Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminShell()),
          );
          return;
        } else if (roleId == 3) {
          // Siswa
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
          return;
        }
      }
    } catch (_) {
      // Fallback jika terjadi error saat membaca cache
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Memeriksa sesi login...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
