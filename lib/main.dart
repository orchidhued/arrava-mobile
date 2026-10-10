import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
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

