import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:arrava_mobile/main.dart';
import 'package:arrava_mobile/admin/modules/providers/module_provider.dart';
import 'package:arrava_mobile/admin/quizzes/providers/quiz_provider.dart';

void main() {
  testWidgets('App smoke test - verifies MyApp loads Login screen successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Build our app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ModuleProvider()),
          ChangeNotifierProvider(create: (_) => QuizProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Gunakan pump dengan durasi tertentu karena halaman login memiliki continuous ticker animasi
    await tester.pump(const Duration(milliseconds: 100));

    // Verifikasi bahwa aplikasi berhasil membuka halaman Login
    expect(find.text('Username atau Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
