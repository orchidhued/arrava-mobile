import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import 'change_password_page.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: AuthService.getSavedUser(),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        final name = userData['name']?.trim();
        final email = userData['email']?.trim();
        final role = userData['role'];
        final isTeacher = role == '2';
        final displayName = (name != null && name.isNotEmpty)
            ? name
            : (isTeacher ? 'Guru / Pendidik' : 'Administrator');
        final displayEmail = (email != null && email.isNotEmpty)
            ? email
            : (isTeacher ? 'guru@arrava.com' : 'admin@arrava.com');
        final displayRole = isTeacher ? 'Guru / Pendidik' : 'Administrator';
        final headerTitle = isTeacher ? 'Profil Guru' : 'Profil Admin';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // ============================================================
                // HEADER
                // ============================================================
                AppHeader(
                  title: headerTitle,
                  onNotificationTap: () {},
                  profileEnabled: false,
                ),

                // ============================================================
                // CONTENT
                // ============================================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(displayName, displayRole),

                        const SizedBox(height: 20),

                        _buildSectionTitle('Informasi Akun'),

                        const SizedBox(height: 10),

                        _buildInfoCard(displayName, displayEmail, displayRole),

                        const SizedBox(height: 20),

                        _buildSectionTitle('Pengaturan & Keamanan'),

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
      },
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(String name, String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow3D,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFF67D7FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFB2E7FC),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFDDF3FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  role,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Akun Aktif',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
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
      style: GoogleFonts.nunitoSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ============================================================
  // ACCOUNT INFORMATION
  // ============================================================

  Widget _buildInfoCard(String name, String email, String role) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow3D,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.person_outline_rounded,
            title: 'Nama',
            value: name,
          ),

          _buildDivider(),

          _buildInfoItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: email,
          ),

          _buildDivider(),

          _buildInfoItem(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Role',
            value: role,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
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
      thickness: 1,
      indent: 66,
      endIndent: 16,
      color: Color(0xFFE8F3FF),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow3D,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.lock_outline_rounded,
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
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Keluar dari akun aplikasi',
            iconColor: const Color(0xFFDC2626),
            titleColor: const Color(0xFFDC2626),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Keluar',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    content: Text(
                      'Apakah kamu yakin ingin keluar dari akun ini?',
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        child: Text(
                          'Batal',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        child: Text(
                          'Keluar',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
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
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
