import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../modules/module_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Beranda',
              onNotificationTap: () {
                // TODO: halaman notifikasi
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),

                    const SizedBox(height: 20),

                    _buildSectionTitle(
                      title: 'Aksi Cepat',
                      trailing: '4 Pintasan',
                    ),

                    const SizedBox(height: 10),

                    _buildQuickActions(context),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      title: 'Ringkasan Statistik',
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Real-time',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildStatisticsGrid(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(
                      title: 'Modul Terbaru',
                      subtitle: 'Aktivitas pembelajaran tertinggi',
                      trailing: 'Lihat Semua ›',
                    ),

                    const SizedBox(height: 10),

                    _buildPopularModules(),
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
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo,',
            style: TextStyle(
              fontSize: 23,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const Text(
            'Administrator',
            style: TextStyle(
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 6),

              const Text(
                'Kamis, 24 September 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    String? subtitle,
    String? trailing,
    Widget? trailingWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(fontSize: 16),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (trailingWidget != null)
          trailingWidget
        else if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTION
  // ============================================================

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildQuickAction(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Tambah Siswa',
            onTap: () {
              // TODO
            },
          ),

          const SizedBox(width: 8),

          _buildQuickAction(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Tambah Guru',
            onTap: () {
              // TODO
            },
          ),

          const SizedBox(width: 8),

          _buildQuickAction(
            icon: Icons.upload_file_outlined,
            label: 'Unggah Modul',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModulePage(),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          _buildQuickAction(
            icon: Icons.analytics_outlined,
            label: 'Lihat Laporan',
            onTap: () {
              // TODO
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return Material(
      color: primary ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: primary
                ? null
                : Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: primary
                    ? Colors.white
                    : AppColors.primary,
              ),

              const SizedBox(width: 7),

              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primary
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.18,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatisticCard(
          icon: Icons.groups_outlined,
          title: 'Siswa Aktif',
          value: '1,428',
          badge: '+12%',
          footerIcon: Icons.trending_up,
          footer: 'Bulan ini',
        ),

        _buildStatisticCard(
          icon: Icons.menu_book_outlined,
          title: 'Total Modul',
          value: '36 Modul',
          badge: '4 Revisi',
          badgeError: true,
          footerIcon: Icons.assignment_late_outlined,
          footer: 'Perlu tinjauan',
          footerError: true,
        ),

        _buildStatisticCard(
          icon: Icons.person_outline,
          title: 'Total Guru',
          value: '32 Guru',
          badge: '+2 bln ini',
          footerIcon: Icons.check_circle_outline,
          footer: '28 Guru Aktif',
        ),

        _buildStatisticCard(
          icon: Icons.person_outline,
          title: 'Total Quiz',
          value: '80 Quiz',
          badge: 'Stabil',
          badgeNeutral: true,
          footerIcon: Icons.remove,
          footer: 'Konsisten minggu ini',
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required String title,
    required String value,
    required String badge,
    required IconData footerIcon,
    required String footer,
    bool badgeError = false,
    bool badgeNeutral = false,
    bool footerError = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeError
                      ? const Color(0xFFFFE7E7)
                      : badgeNeutral
                          ? const Color(0xFFEFF1F7)
                          : const Color(0xFFD9FBEA),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: badgeError
                        ? AppColors.error
                        : badgeNeutral
                            ? AppColors.textSecondary
                            : AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Icon(
                footerIcon,
                size: 13,
                color: footerError
                    ? AppColors.error
                    : AppColors.success,
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  footer,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: footerError
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // POPULAR MODULES
  // ============================================================

  Widget _buildPopularModules() {
    return Column(
      children: [
        _buildModuleCard(
          icon: Icons.edit_outlined,
          title: 'UI/UX Design Fundamental',
          students: '340 siswa aktif',
          progress: 0.92,
          progressText: '92%',
          status: 'Aktif',
          iconColor: AppColors.primary,
        ),

        const SizedBox(height: 9),

        _buildModuleCard(
          icon: Icons.code_outlined,
          title: 'Fullstack Web Development',
          students: '285 siswa aktif',
          progress: 0.78,
          progressText: '78%',
          status: 'Aktif',
          iconColor: AppColors.primary,
        ),

        const SizedBox(height: 9),

        _buildModuleCard(
          icon: Icons.analytics_outlined,
          title: 'Data Analytics with Python',
          students: '190 siswa aktif',
          progress: 0.64,
          progressText: '64%',
          status: 'Review',
          review: true,
          iconColor: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String students,
    required double progress,
    required String progressText,
    required String status,
    required Color iconColor,
    bool review = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      students,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: review
                      ? const Color(0xFFEFF1F7)
                      : const Color(0xFFD9FBEA),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: review
                        ? AppColors.textSecondary
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              const Text(
                'Tingkat Progres',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              Text(
                progressText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.primaryLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                review
                    ? AppColors.textSecondary
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}