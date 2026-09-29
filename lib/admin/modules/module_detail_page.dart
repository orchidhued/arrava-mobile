import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';

class ModuleDetailPage extends StatelessWidget {
  final String moduleName;
  final String category;
  final String description;
  final String teacher;
  final String status;
  final String date;

  const ModuleDetailPage({
    super.key,
    required this.moduleName,
    required this.category,
    required this.description,
    required this.teacher,
    required this.status,
    required this.date,
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
                title: 'Detail Modul',
                onNotificationTap: () {
                  // TODO: notifikasi
                },
              ),

              const SizedBox(height: 20),

              _buildModuleHeader(isActive),

              const SizedBox(height: 20),

              _buildSectionTitle('Informasi Modul'),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.category_outlined,
                title: 'Kategori',
                value: category,
              ),

              _buildInfoCard(
                icon: Icons.person_outline,
                title: 'Guru Pengampu',
                value: teacher,
              ),

              _buildInfoCard(
                icon: Icons.calendar_today_outlined,
                title: 'Tanggal Dibuat',
                value: date,
              ),

              _buildInfoCard(
                icon: Icons.people_outline,
                title: 'Jumlah Siswa',
                value: '32 siswa',
              ),

              const SizedBox(height: 20),

              _buildSectionTitle('Deskripsi'),

              const SizedBox(height: 12),

              _buildDescription(),

              const SizedBox(height: 24),

              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleHeader(bool isActive) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moduleName,
                  style: AppTextStyles.heading3,
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
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
                      'Form edit modul akan dibuat berikutnya.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Modul'),
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
                'Hapus Modul',
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
          title: const Text('Hapus Modul'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "$moduleName"?',
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
}