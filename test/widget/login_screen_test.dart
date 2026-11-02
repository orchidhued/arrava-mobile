import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrava_mobile/auth/login.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all login form elements properly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Gunakan pump durasi karena LoginScreen memiliki continuous ticker background
      await tester.pump(const Duration(milliseconds: 100));

      // Check fields
      expect(find.text('Username atau Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Ingat saya'), findsOneWidget);
      expect(find.text('Lupa Password?'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('Shows validation errors when submitting empty form', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Click "Masuk" button without filling the form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump(const Duration(milliseconds: 50));

      // Verify validation error messages
      expect(find.text('Username atau email wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    });
  });
}
