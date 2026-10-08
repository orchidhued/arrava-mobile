import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import 'change_password_page.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            AppHeader(
              title: 'Profil Admin',
              onNotificationTap: () {
                // TODO: buka halaman notifikasi
              },

              // Profile dimatikan karena sedang berada di halaman Profil.
              profileEnabled: false,
            ),

            // ============================================================
            // CONTENT
            // ============================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),

                    const SizedBox(height: 18),

                    _buildSectionTitle('Informasi Akun'),

                    const SizedBox(height: 10),

                    _buildInfoCard(),

                    const SizedBox(height: 18),

                    _buildSectionTitle('Pengaturan'),

                    const SizedBox(height: 10),

                    _buildSettingsCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 34, color: AppColors.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Admin Sistem',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9FBEA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Akun Aktif',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00875A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ============================================================
  // ACCOUNT INFORMATION
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.person_outline,
            title: 'Nama',
            value: 'Administrator',
          ),

          _buildDivider(),

          _buildInfoItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'admin@arrava.com',
          ),

          _buildDivider(),

          _buildInfoItem(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Role',
            value: 'Administrator',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 64,
      endIndent: 15,
      color: AppColors.border,
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            subtitle: 'Ubah informasi akun admin',
            onTap: () {
              // TODO: Edit profil
            },
          ),

          _buildDivider(),

          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            subtitle: 'Perbarui password akun',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),

          _buildDivider(),

          _buildSettingItem(
            icon: Icons.logout,
            title: 'Keluar',
            subtitle: 'Keluar dari akun administrator',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text(
                      'Keluar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    content: const Text(
                      'Apakah kamu yakin ingin keluar dari akun administrator?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        child: const Text('Batal'),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmed != true) return;

              // Tampilkan loading kecil
              if (!context.mounted) return;

              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              try {
                await AuthService.logout();

                if (!context.mounted) return;

                // Tutup loading
                Navigator.pop(context);

                // Kembali ke halaman login dan hapus seluruh history halaman sebelumnya
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (e) {
                if (!context.mounted) return;

                // Tutup loading
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 19,
                color: iconColor ?? AppColors.primary,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
