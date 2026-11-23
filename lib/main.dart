import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:arrava_mobile/admin/dungeon/providers/dungeon_provider.dart';
import 'package:arrava_mobile/admin/modules/providers/module_provider.dart';
import 'package:arrava_mobile/admin/quizzes/providers/quiz_provider.dart';
import 'package:arrava_mobile/providers/notification_provider.dart';
import 'package:arrava_mobile/auth/login.dart';
import 'package:arrava_mobile/core/theme/app_theme.dart';
import 'package:arrava_mobile/shared/screens/splash_screen.dart';
import 'package:arrava_mobile/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DungeonProvider()),
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
      title: 'ARRAVA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {'/login': (_) => const LoginScreen()},
      home: const SplashScreen(),
    );
  }
}
