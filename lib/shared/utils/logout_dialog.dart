import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

/// Menampilkan dialog konfirmasi keluar dan melakukan proses logout
Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Keluar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini? Anda harus login kembali untuk mengakses materi pembelajaran.',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) return;

  // Tampilkan loading overlay saat logout
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    await AuthService.logout();
  } catch (_) {}

  if (!context.mounted) return;

  // Tutup loading dialog jika masih mounted
  Navigator.of(context, rootNavigator: true).pop();

  // Pindah ke halaman Login dan bersihkan seluruh tumpukan route
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Anda telah berhasil keluar dari akun.'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

