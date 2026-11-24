import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'package:arrava_mobile/core/network/api_client.dart';
import 'package:arrava_mobile/core/constants/api_constants.dart';
import 'package:arrava_mobile/services/auth_service.dart';
import 'package:arrava_mobile/core/storage/secure_storage.dart';
import 'package:arrava_mobile/admin/admin_shell.dart';
import 'package:arrava_mobile/screens/dashboard_screen.dart';
import 'package:arrava_mobile/parent/parent_dashboard_screen.dart';
import 'package:arrava_mobile/auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _timeout;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _openLogin();
      });
    // Keep startup usable even if the animation cannot load.
    _timeout = Timer(const Duration(seconds: 8), _openLogin);
  }

  Future<void> _openLogin() async {
    if (!mounted || _finished) return;
    _finished = true;
    _timeout.cancel();

    // 1. Periksa apakah pengguna sedang login & mengaktifkan 'Ingat Saya'
    final bool loggedIn = await AuthService.isLoggedIn();
    final String? rememberMe = await SecureStorage.read('remember_me');

    if (loggedIn && rememberMe == 'true' && mounted) {
      try {
        final meResponse = await ApiClient.get(ApiConstants.me)
            .timeout(const Duration(seconds: 4));
        if (meResponse is Map && meResponse['success'] == true && mounted) {
          final user = meResponse['user'];
          final int role = (user != null && user['id_tipeuser'] != null)
              ? int.tryParse(user['id_tipeuser'].toString()) ?? 0
              : int.tryParse(await AuthService.getRole() ?? '') ?? 0;

          if (user != null) {
            await SecureStorage.write('user_role', role.toString());
            if (user['id_jenjang'] != null) {
              await SecureStorage.write(
                'user_jenjang',
                user['id_jenjang'].toString(),
              );
            }
          }

          Widget destinationPage;
          if (role == 1) {
            destinationPage = const AdminShell();
          } else if (role == 2) {
            destinationPage = const AdminShell(isTeacher: true);
          } else if (role == 3) {
            destinationPage = const DashboardScreen();
          } else if (role == 4) {
            destinationPage = const ParentDashboardScreen();
          } else {
            destinationPage = const LoginScreen();
          }

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => destinationPage,
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
          return;
        }
      } catch (_) {
        // Token tidak valid atau sesi server berakhir, bersihkan token lama
        await SecureStorage.delete('auth_token');
      }
    }

    // 2. Jika belum login atau tidak mencentang Ingat Saya, arahkan ke /login
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _timeout.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Center(
            child: Lottie.asset(
              'assets/animations/splash.json',
              controller: _controller,
              repeat: false,
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).width * 422 / 964,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                if (!mounted || _finished) return;
                _controller
                  ..duration = composition.duration
                  ..forward();
              },
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _openLogin(),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
