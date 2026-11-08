import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_colors.dart';
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo,',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 20,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userName.isNotEmpty
                          ? _userName
                          : (_isTeacher ? 'Bapak/Ibu Guru' : 'Administrator'),
                      style: GoogleFonts.nunitoSans(
                        fontSize: 24,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => showLogoutConfirmationDialog(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFCDD2),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFCDD2),
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDC2626),
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDDF3FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _getFormattedDate(),
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              if (subtitle != null) ...[
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
            ],
          ),
        ),

        if (trailingWidget != null)
          trailingWidget
        else if (trailing != null)
          Text(
            trailing,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
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
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildQuickAction(
            icon: Icons.menu_book_rounded,
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
    return Container(
      decoration: BoxDecoration(
        color: primary ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary ? AppColors.primaryDark : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primary ? AppColors.primaryDark : AppColors.shadow3D,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: primary ? Colors.white : AppColors.primary,
                ),

                const SizedBox(width: 8),

                Text(
                  label,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: primary ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
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
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatisticCard(
          icon: Icons.groups_rounded,
          title: 'Total Siswa',
          value: '$totalSiswa',
          badge: 'Aktif',
          footerIcon: Icons.check_circle_rounded,
          footer: 'Terdaftar di database',
        ),

        _buildStatisticCard(
          icon: Icons.menu_book_rounded,
          title: 'Total Modul',
          value: '$totalModul Modul',
          badge: 'Tersedia',
          footerIcon: Icons.library_books_rounded,
          footer: 'Modul pembelajaran',
        ),

        _buildStatisticCard(
          icon: Icons.person_rounded,
          title: 'Total Guru',
          value: '$totalGuru Guru',
          badge: 'Pendidik',
          footerIcon: Icons.verified_user_rounded,
          footer: 'Tenaga pengajar',
        ),

        _buildStatisticCard(
          icon: Icons.quiz_rounded,
          title: 'Total Quiz',
          value: '$totalQuiz Quiz',
          badge: 'Interaktif',
          footerIcon: Icons.bolt_rounded,
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
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeError
                      ? const Color(0xFFFFECEE)
                      : badgeNeutral
                      ? const Color(0xFFEFF1F7)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: badgeError
                        ? const Color(0xFFFFCDD2)
                        : badgeNeutral
                        ? const Color(0xFFDCEFFF)
                        : const Color(0xFFA7F3D0),
                    width: 1,
                  ),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeError
                        ? AppColors.error
                        : badgeNeutral
                        ? AppColors.textSecondary
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Icon(
                footerIcon,
                size: 13,
                color: footerError ? AppColors.error : const Color(0xFF059669),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  footer,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.all(24),
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
        child: Center(
          child: Text(
            'Belum ada modul di database.',
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: modules.map((m) {
        final isDraft = m['status'] == 'Draft';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildModuleCard(
            icon: Icons.menu_book_rounded,
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: resolvedCoverUrl != null
                ? Image.network(
                    resolvedCoverUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 52,
                      height: 52,
                      color: AppColors.primaryLight,
                      child: Icon(icon, size: 22, color: iconColor),
                    ),
                  )
                : Container(
                    width: 52,
                    height: 52,
                    color: AppColors.primaryLight,
                    child: Icon(icon, size: 22, color: iconColor),
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDraft
                  ? const Color(0xFFEFF1F7)
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDraft
                    ? const Color(0xFFDCEFFF)
                    : const Color(0xFFA7F3D0),
                width: 1,
              ),
            ),
            child: Text(
              status,
              style: GoogleFonts.nunitoSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isDraft
                    ? AppColors.textSecondary
                    : const Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
