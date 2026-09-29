import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';

class TeacherDetailPage extends StatelessWidget {
  final String name;
  final String nip;
  final String subject;
  final String role;
  final String status;

  const TeacherDetailPage({
    super.key,
    required this.name,
    required this.nip,
    required this.subject,
    required this.role,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status.toLowerCase() == 'aktif';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: 'Detail Guru',
                onNotificationTap: () {},
              ),

              const SizedBox(height: 20),

              _buildTeacherHeader(isActive),

              const SizedBox(height: 20),

              _buildSectionTitle('Informasi Guru'),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.badge_outlined,
                title: 'NIP',
                value: nip,
              ),

              _buildInfoCard(
                icon: Icons.menu_book_outlined,
                title: 'Mata Pelajaran',
                value: subject,
              ),

              _buildInfoCard(
                icon: Icons.work_outline,
                title: 'Role',
                value: role,
              ),

              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: 'guru@eduadminpro.com',
              ),

              _buildInfoCard(
                icon: Icons.phone_outlined,
                title: 'Nomor HP',
                value: '0812 3456 7890',
              ),

              const SizedBox(height: 24),

              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherHeader(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(name),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading3,
                ),

                const SizedBox(height: 5),

                Text(
                  nip,
                  style: AppTextStyles.bodySecondary,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success
                            : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppTextStyles.heading3,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Form edit guru akan dibuat berikutnya.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Guru'),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _showDeleteDialog(context);
              },
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              label: Text(
                'Hapus Guru',
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.error.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Guru'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data "$name"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur hapus akan dihubungkan ke database nanti.',
                    ),
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
        '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}