import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/dungeon/dungeon_lobby.dart';
import '../../services/dashboard_service.dart';
import '../../shared/utils/logout_dialog.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/notification_sheet.dart';
import '../../shared/widgets/tween_float_background.dart';
import '../attendance/attendance_page.dart';
import '../modules/module_page.dart';
import '../profile/admin_profile_page.dart';
import '../quizzes/quiz_menu_page.dart';
import '../students/student_page.dart';
import '../teachers/teacher_page.dart';

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
          if (data['user'] is Map) {
            final u = data['user'] as Map;
            if (u['nama'] != null && u['nama'].toString().trim().isNotEmpty) {
              _userName = u['nama'].toString().trim();
            }
            if (u['id_tipeuser']?.toString() == '2') {
              _isTeacher = true;
            }
          }
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
    final recentStudents =
        (_adminData?['siswa_terbaru'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    final pageTitle = _isTeacher ? 'Portal Guru' : 'Portal Administrator';

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: pageTitle,
              onLogoutTap: () => showLogoutConfirmationDialog(context),
              onNotificationTap: () => NotificationSheet.show(context),
            ),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadDashboard,
                child: TweenFloatBackground(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. GREETING BANNER KHAS ELEARNINGARRAVA
                        _buildGreetingBanner(context),

                        const SizedBox(height: 18),

                        // 2. AKSI CEPAT / PINTASAN
                        _buildSectionHeader(
                          title: 'Aksi Cepat',
                          trailingText: 'Pintasan',
                        ),

                        const SizedBox(height: 10),

                        _buildQuickActions(context),

                        const SizedBox(height: 24),

                        // 3. STATISTIK 3D SAMUDRA STYLE (5 KARTU KHAS WEB)
                        _buildSectionHeader(
                          title: 'Ringkasan Statistik',
                          trailingWidget: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF059669),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Real-time',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11,
                                  color: const Color(0xFF059669),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

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
                          _buildStatisticsGrid(context, stats),

                        const SizedBox(height: 24),

                        // 4. SISWA PENDAFTARAN TERBARU (KHAS WEB)
                        if (!_isTeacher || recentStudents.isNotEmpty) ...[
                          _buildSectionHeader(
                            title: '👥 Siswa Pendaftaran Terbaru',
                            trailingText: !_isTeacher ? 'Lihat Semua →' : null,
                            onTrailingTap: !_isTeacher
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const StudentPage(),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _buildRecentStudentsCard(recentStudents),
                          const SizedBox(height: 24),
                        ],

                        // 5. MODUL TERBARU (KHAS WEB)
                        _buildSectionHeader(
                          title: '📚 Modul Terbaru',
                          trailingText: 'Kelola Modul →',
                          onTrailingTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ModulePage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        _buildRecentModulesCard(recentModules),
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
  // 1. GREETING BANNER 3D SAMUDRA (PERSIS ADMIN.BLADE.PHP)
  // ============================================================
  Widget _buildGreetingBanner(BuildContext context) {
    final displayName = _userName.isNotEmpty
        ? _userName
        : (_isTeacher ? 'Bapak/Ibu Guru' : 'Admin');
    final portalBadge = _isTeacher
        ? '🧑‍🏫 Portal Guru Arrava'
        : '🛡️ Portal Administrator Arrava';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF007FBE),
            Color(0xFF0095DE),
            Color(0xFF38BDF8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF005580),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative glowing blurred circle
          Positioned(
            right: -25,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Pill Portal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    portalBadge,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Greeting Headline
                Text(
                  'Selamat datang kembali, $displayName! 👋',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    shadows: const [
                      Shadow(
                        color: Color(0x66004566),
                        offset: Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Berikut ringkasan perkembangan belajar, data pengguna, modul, dan evaluasi platform hari ini.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 12),

                // Date badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getFormattedDate(),
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
  // 2. SECTION HEADER
  // ============================================================
  Widget _buildSectionHeader({
    required String title,
    String? trailingText,
    Widget? trailingWidget,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF082765),
          ),
        ),
        if (trailingWidget != null)
          trailingWidget
        else if (trailingText != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailingText,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF007FBE),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // 3. QUICK ACTIONS
  // ============================================================
  Widget _buildQuickActions(BuildContext context) {
    final actions = _isTeacher
        ? [
            _QuickActionItem(
              icon: Icons.menu_book_rounded,
              label: 'Modul',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModulePage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.quiz_rounded,
              label: 'Kuis',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizMenuPage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Presensi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendancePage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.castle_rounded,
              label: 'Dungeon',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DungeonLobbyPage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfilePage()),
              ),
            ),
          ]
        : [
            _QuickActionItem(
              icon: Icons.menu_book_rounded,
              label: 'Modul',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModulePage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.quiz_rounded,
              label: 'Kuis',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizMenuPage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.people_rounded,
              label: 'Siswa',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentPage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.school_rounded,
              label: 'Guru',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeacherPage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Presensi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendancePage()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.castle_rounded,
              label: 'Dungeon',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DungeonLobbyPage()),
              ),
            ),
          ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => actions[index],
      ),
    );
  }

  // ============================================================
  // 4. STATISTIK GRID 3D SAMUDRA (5 KARTU PERSIS WEB)
  // ============================================================
  Widget _buildStatisticsGrid(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final totalSiswa = stats['total_siswa'] ?? 0;
    final totalGuru = stats['total_guru'] ?? 0;
    final totalModul = stats['total_modul'] ?? 0;
    final totalQuiz = stats['total_quiz'] ?? 0;
    final totalAchievement = stats['total_achievement'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            // Card 1: Siswa (Cyan)
            Expanded(
              child: _build3DStatCard(
                icon: Icons.groups_rounded,
                badgeText: 'SISWA',
                badgeBg: const Color(0xFFDDF3FF),
                badgeTextCol: const Color(0xFF007FBE),
                badgeBorder: const Color(0xFFB2E7FC),
                iconBg: const Color(0xFFDDF3FF),
                iconColor: const Color(0xFF007FBE),
                label: 'Total Siswa',
                value: '$totalSiswa',
                onTap: !_isTeacher
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentPage()),
                        )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            // Card 2: Guru (Indigo)
            Expanded(
              child: _build3DStatCard(
                icon: Icons.school_rounded,
                badgeText: 'GURU',
                badgeBg: const Color(0xFFEEF2FF),
                badgeTextCol: const Color(0xFF4F46E5),
                badgeBorder: const Color(0xFFC7D2FE),
                iconBg: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF4F46E5),
                label: 'Total Guru',
                value: '$totalGuru',
                onTap: !_isTeacher
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TeacherPage()),
                        )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 3: Modul (Green)
            Expanded(
              child: _build3DStatCard(
                icon: Icons.menu_book_rounded,
                badgeText: 'MODUL',
                badgeBg: const Color(0xFFDCFCE7),
                badgeTextCol: const Color(0xFF059669),
                badgeBorder: const Color(0xFFBBF7D0),
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF059669),
                label: 'Total Modul',
                value: '$totalModul',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ModulePage()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Card 4: Kuis (Amber)
            Expanded(
              child: _build3DStatCard(
                icon: Icons.quiz_rounded,
                badgeText: 'KUIS',
                badgeBg: const Color(0xFFFEF3C7),
                badgeTextCol: const Color(0xFFD97706),
                badgeBorder: const Color(0xFFFDE68A),
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                label: 'Total Kuis',
                value: '$totalQuiz',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizMenuPage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Card 5: Penghargaan (Rose) - Full width
        _build3DStatCard(
          icon: Icons.emoji_events_rounded,
          badgeText: 'PENGHARGAAN',
          badgeBg: const Color(0xFFFFE4E6),
          badgeTextCol: const Color(0xFFE11D48),
          badgeBorder: const Color(0xFFFECDD3),
          iconBg: const Color(0xFFFFE4E6),
          iconColor: const Color(0xFFE11D48),
          label: 'Penghargaan',
          value: '$totalAchievement',
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _build3DStatCard({
    required IconData icon,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextCol,
    required Color badgeBorder,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    bool isFullWidth = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEFFF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB2E7FC),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isFullWidth ? 14 : 12,
            ),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: badgeBorder, width: 1.2),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF72839E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: badgeBorder, width: 1),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: badgeTextCol,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF082765),
                        ),
                      ),
                    ],
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
  // 5. SISWA PENDAFTARAN TERBARU CARD
  // ============================================================
  Widget _buildRecentStudentsCard(List<Map<String, dynamic>> students) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCEFFF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB2E7FC),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: students.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada data siswa.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF72839E),
                  ),
                ),
              ),
            )
          : Column(
              children: students.map((s) {
                final nama = s['nama']?.toString() ?? 'Siswa';
                final email = s['email']?.toString() ?? '-';
                final timeAgo = s['created_at']?.toString() ?? '-';
                final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'S';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDCEFFF),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar Initial
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF3FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFB2E7FC),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF007FBE),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Name and Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF082765),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF72839E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time ago badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDCEFFF),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            timeAgo,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF72839E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ============================================================
  // 6. MODUL TERBARU CARD
  // ============================================================
  Widget _buildRecentModulesCard(List<Map<String, dynamic>> modules) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCEFFF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB2E7FC),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: modules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada modul tersedia.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF72839E),
                  ),
                ),
              ),
            )
          : Column(
              children: modules.map((m) {
                final judul = m['judul_modul']?.toString() ?? 'Modul';
                final jenjang = m['jenjang']?.toString() ?? 'Semua';
                final tipe = m['tipe']?.toString() ?? 'Materi';
                final status = m['status']?.toString() ?? 'Tersedia';
                final isDraft = status.toLowerCase() == 'draft';
                final fotoUrl = m['foto_modul']?.toString();
                final youtubeId = m['youtube_id']?.toString();

                String? thumbnail;
                if (fotoUrl != null && fotoUrl.isNotEmpty) {
                  thumbnail = ApiConstants.resolveMediaUrl(fotoUrl);
                } else if (youtubeId != null && youtubeId.isNotEmpty) {
                  thumbnail =
                      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDCEFFF),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDF3FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFB2E7FC),
                                width: 1,
                              ),
                            ),
                            child: thumbnail != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        thumbnail,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.menu_book_rounded,
                                          color: Color(0xFF007FBE),
                                          size: 20,
                                        ),
                                      ),
                                      if (youtubeId != null &&
                                          youtubeId.isNotEmpty)
                                        Container(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : const Icon(
                                    Icons.menu_book_rounded,
                                    color: Color(0xFF007FBE),
                                    size: 20,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF082765),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$tipe • $jenjang',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF72839E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDraft
                                ? const Color(0xFFEFF1F7)
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDraft
                                  ? const Color(0xFFDCEFFF)
                                  : const Color(0xFFBBF7D0),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDraft
                                  ? const Color(0xFF72839E)
                                  : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCEFFF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB2E7FC),
            offset: Offset(0, 3),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: const Color(0xFF007FBE)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF082765),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
