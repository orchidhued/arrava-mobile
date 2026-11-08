import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/dashboard_service.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/tween_float_background.dart';
import '../../shared/utils/logout_dialog.dart';
import '../modules/module_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final bool isTeacher;
  const AdminDashboardPage({super.key, this.isTeacher = false});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _adminData;
  String _userName = '';
  late bool _isTeacher;

  @override
  void initState() {
    super.initState();
    _isTeacher = widget.isTeacher;
    _loadUserData();
    _loadDashboard();
  }

  Future<void> _loadUserData() async {
    try {
      final name = await SecureStorage.read('user_name');
      final role = await SecureStorage.read('user_role');
      if (mounted) {
        setState(() {
          if (name != null && name.trim().isNotEmpty) {
            _userName = name.trim();
          }
          if (role == '2') {
            _isTeacher = true;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await DashboardService.fetchAdminDashboard();
      if (mounted) {
        setState(() {
          _adminData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final stats = (_adminData?['stats'] as Map<String, dynamic>?) ?? {};
    final recentModules =
        (_adminData?['recent_modules'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: _isTeacher ? 'Beranda Guru' : 'Beranda Admin',
              onLogoutTap: () => showLogoutConfirmationDialog(context),
              onNotificationTap: () {},
            ),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadDashboard,
                child: TweenFloatBackground(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeCard(context),

                        const SizedBox(height: 20),

                        _buildSectionTitle(
                          title: 'Aksi Cepat',
                          trailing: 'Pintasan',
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
                                'Real-time Database',
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

                        if (_isLoading && _adminData == null)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else
                          _buildStatisticsGrid(stats),

                        const SizedBox(height: 26),

                        _buildSectionTitle(
                          title: 'Modul Terbaru',
                          subtitle: 'Terhubung dengan database modul',
                        ),

                        const SizedBox(height: 10),

                        _buildPopularModules(recentModules),
                      ],
                    ),
                  ),
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

  Widget _buildWelcomeCard(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                  Text(
                    _userName.isNotEmpty
                        ? _userName
                        : (_isTeacher ? 'Bapak/Ibu Guru' : 'Administrator'),
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => showLogoutConfirmationDialog(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 6),

              Text(
                _getFormattedDate(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
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
              Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 16)),

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
            icon: Icons.menu_book_outlined,
            label: 'Kelola Modul',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ModulePage()),
              );
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: primary ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: primary ? Colors.white : AppColors.primary,
              ),

              const SizedBox(width: 7),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary ? Colors.white : AppColors.textPrimary,
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

  Widget _buildStatisticsGrid(Map<String, dynamic> stats) {
    final totalSiswa = stats['total_siswa'] ?? 0;
    final totalModul = stats['total_modul'] ?? 0;
    final totalGuru = stats['total_guru'] ?? 0;
    final totalQuiz = stats['total_quiz'] ?? 0;

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
          title: 'Total Siswa',
          value: '$totalSiswa',
          badge: 'Aktif',
          footerIcon: Icons.check_circle_outline,
          footer: 'Terdaftar di database',
        ),

        _buildStatisticCard(
          icon: Icons.menu_book_outlined,
          title: 'Total Modul',
          value: '$totalModul Modul',
          badge: 'Tersedia',
          footerIcon: Icons.library_books_outlined,
          footer: 'Modul pembelajaran',
        ),

        _buildStatisticCard(
          icon: Icons.person_outline,
          title: 'Total Guru',
          value: '$totalGuru Guru',
          badge: 'Pendidik',
          footerIcon: Icons.verified_user_outlined,
          footer: 'Tenaga pengajar',
        ),

        _buildStatisticCard(
          icon: Icons.quiz_outlined,
          title: 'Total Quiz',
          value: '$totalQuiz Quiz',
          badge: 'Interaktif',
          footerIcon: Icons.bolt_outlined,
          footer: 'Kuis evaluasi',
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
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
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
              fontSize: 22,
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
                color: footerError ? AppColors.error : AppColors.success,
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

  Widget _buildPopularModules(List<Map<String, dynamic>> modules) {
    if (modules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Belum ada modul di database.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: modules.map((m) {
        final isDraft = m['status'] == 'Draft';
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _buildModuleCard(
            icon: Icons.menu_book_outlined,
            title: m['judul_modul']?.toString() ?? 'Modul',
            subtitle:
                '${m['tipe'] ?? 'Materi'} • Jenjang ${m['jenjang'] ?? 'Semua'}',
            status: m['status']?.toString() ?? 'Tersedia',
            isDraft: isDraft,
            iconColor: isDraft ? AppColors.textSecondary : AppColors.primary,
            coverUrl:
                m['foto_url']?.toString() ??
                m['foto_modul']?.toString() ??
                (m['youtube_id']?.toString().isNotEmpty == true
                    ? 'https://img.youtube.com/vi/${m['youtube_id']}/hqdefault.jpg'
                    : null),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color iconColor,
    bool isDraft = false,
    String? coverUrl,
  }) {
    final resolvedCoverUrl = ApiConstants.resolveMediaUrl(coverUrl);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: resolvedCoverUrl != null
                ? Image.network(
                    resolvedCoverUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.primaryLight,
                      child: Icon(icon, size: 20, color: iconColor),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: AppColors.primaryLight,
                    child: Icon(icon, size: 20, color: iconColor),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDraft
                  ? const Color(0xFFEFF1F7)
                  : const Color(0xFFD9FBEA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDraft ? AppColors.textSecondary : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
