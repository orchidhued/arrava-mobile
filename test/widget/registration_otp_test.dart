import 'dart:convert';

import 'package:arrava_mobile/auth/registration.dart';
import 'package:arrava_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('registration shows student, parent and OTP in sequence', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(640, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var submissions = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        expect(request.url.path, '/api/pendaftaran/jenjang');
        return http.Response(
          '{"data":[{"id_jenjang":1,"nama_tipe":"SMA"}]}',
          200,
        );
      }
      expect(request.url.path, '/api/pendaftaran');
      submissions++;
      final body = jsonDecode(request.body) as Map;
      expect(body['email'], 'siswa@example.com');
      expect(body['email_orangtua'], 'wali@example.com');
      expect(body.containsKey('password_orangtua'), isFalse);
      return http.Response(
        '{"success":true,"registration_id":"challenge","email":"siswa@example.com","retry_after":60}',
        201,
      );
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Informasi akun siswa'), findsOneWidget);
      expect(find.text('Nama orang tua'), findsNothing);
      final fields = find.byType(TextFormField);
      for (final (index, value) in [
        'Siswa Contoh',
        'siswa@example.com',
        '0012345678',
        '081234567890',
        'KataSandi123',
        'KataSandi123',
      ].indexed) {
        await tester.enterText(fields.at(index), value);
      }
      await tester.tap(find.text('Jenjang pendidikan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SMA').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut: Data Orang Tua'));
      await tester.pumpAndSettle();
      expect(find.text('Informasi akun orang tua'), findsOneWidget);
      expect(find.text('Nama siswa'), findsNothing);
      expect(submissions, 0);

      await tester.enterText(fields.at(0), 'Wali Contoh');
      await tester.tap(find.text('Kembali ke data siswa'));
      await tester.pumpAndSettle();
      expect(find.text('siswa@example.com'), findsOneWidget);
      await tester.tap(find.text('Lanjut: Data Orang Tua'));
      await tester.pumpAndSettle();
      expect(find.text('Wali Contoh'), findsOneWidget);
      await tester.enterText(fields.at(1), 'wali@example.com');
      await tester.enterText(fields.at(2), '081234567890');
      await tester.tap(find.text('Kirim kode ke email siswa'));
      await tester.pumpAndSettle();
      expect(submissions, 1);
      expect(find.text('Verifikasi email siswa'), findsOneWidget);
      expect(find.textContaining('siswa@example.com'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
  });

  testWidgets('OTP keeps leading zeroes and honors resend cooldown', (
    tester,
  ) async {
    var resends = 0;
    var verifications = 0;
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map;
      expect(body['registration_id'], 'challenge');
      expect(request.headers['authorization'], isNull);
      if (request.url.path.endsWith('/kirim-ulang')) {
        resends++;
        return http.Response('{"success":true,"retry_after":25}', 200);
      }
      verifications++;
      expect(body['code'], '012345');
      if (verifications == 1) {
        return http.Response('{"message":"Kode OTP salah."}', 422);
      }
      return http.Response('{"message":"Kode OTP kedaluwarsa."}', 422);
    });

    final startedAt = tester.binding.clock.now();
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationOtpScreen(
            registrationId: 'challenge',
            email: 'siswa@example.com',
            retryAfter: const Duration(seconds: 60),
            elapsed: () => tester.binding.clock.now().difference(startedAt),
          ),
        ),
      );
      expect(find.textContaining('siswa@example.com'), findsOneWidget);
      final resend = find.widgetWithText(TextButton, 'Kirim ulang kode');
      expect(find.text('Kirim ulang tersedia dalam 60 detik.'), findsOneWidget);
      expect(tester.widget<TextButton>(resend).onPressed, isNull);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Kirim ulang tersedia dalam 59 detik.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Kirim ulang tersedia dalam 58 detik.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 57));
      expect(find.text('Kirim ulang tersedia dalam 1 detik.'), findsOneWidget);
      expect(tester.widget<TextButton>(resend).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField), '012345');
      final verify = find.widgetWithText(ElevatedButton, 'Verifikasi kode');
      await tester.tap(verify);
      await tester.pumpAndSettle();
      expect(find.text('Kode OTP salah.'), findsOneWidget);
      await tester.tap(verify);
      await tester.pumpAndSettle();
      expect(find.text('Kode OTP kedaluwarsa.'), findsOneWidget);
      expect(resends, 0);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<TextButton>(resend).onPressed, isNotNull);
      expect(find.textContaining('Kirim ulang tersedia'), findsNothing);
      await tester.tap(resend);
      await tester.pumpAndSettle();
      expect(resends, 1);
      expect(find.text('Kode baru sudah dikirim.'), findsOneWidget);
      expect(find.text('Kirim ulang tersedia dalam 25 detik.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Kirim ulang tersedia dalam 24 detik.'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
    }, () => client);
  });

  test('restores saved session via me, preserves it offline, clears rejected token', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'saved-token'});
    var response = 200;
    await http.runWithClient(
      () async {
        expect(await AuthService.restoreRole(), '3');
        response = 503;
        expect(await AuthService.restoreRole(), '3');
        expect(await AuthService.getToken(), 'saved-token');
        response = 401;
        expect(await AuthService.restoreRole(), isNull);
        expect(await AuthService.getToken(), isNull);
      },
      () => MockClient((request) async {
        expect(request.url.path, '/api/me');
        expect(request.headers['authorization'], 'Bearer saved-token');
        return response == 200
            ? http.Response('{"success":true,"user":{"id_tipeuser":3}}', 200)
            : http.Response('{"message":"Error"}', response);
      }),
    );
  });
}
