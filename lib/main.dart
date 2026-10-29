import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:arrava_mobile/admin/modules/providers/module_provider.dart';
import 'package:arrava_mobile/admin/quizzes/providers/quiz_provider.dart';
import 'package:arrava_mobile/auth/login.dart';
import 'package:arrava_mobile/core/theme/app_theme.dart';

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
      routes: {
        '/login': (_) => const LoginScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
