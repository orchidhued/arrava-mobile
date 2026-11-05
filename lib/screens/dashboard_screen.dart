import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../shared/utils/logout_dialog.dart';
import '../shared/widgets/tween_float_background.dart';
import 'modules/student_module_list_page.dart';
import 'profile/student_profile_page.dart';
import 'quizzes/student_quiz_list_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  static const _blue = Color(0xFF2563EB);
  static const _indigo = Color(0xFF4F46E5);
  static const _green = Color(0xFF059669);
  static const _orange = Color(0xFFD97706);

  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await DashboardService.fetchStudentDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 1) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const SafeArea(child: StudentModuleListPage()),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    if (_currentIndex == 2) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const SafeArea(child: StudentQuizListPage()),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    if (_currentIndex == 3) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const SafeArea(child: StudentProfilePage()),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    final user = _dashboardData?['user'] as Map<String, dynamic>?;
    final stats = _dashboardData?['stats'] as Map<String, dynamic>?;
    final materiList =
        (_dashboardData?['materi_terbaru'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final riwayatList =
        (_dashboardData?['riwayat_belajar'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: TweenFloatBackground(
          scrollController: _scrollController,
          child: RefreshIndicator(
            color: _blue,
            onRefresh: _loadDashboard,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                final bool isDesktop = maxWidth >= 880;
                final bool isTablet = maxWidth >= 600 && maxWidth < 880;

                if (_isLoading && _dashboardData == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: _blue),
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 28 : (isTablet ? 20 : 16),
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===================================================
                          // 1. TOP HEADER BAR: Profile, Level, XP & Logout
                          // ===================================================
                          _buildTopHeader(user, stats),

                          const SizedBox(height: 18),

                          // ===================================================
                          // 2. STATS ROW / GRID
                          // ===================================================
                          _buildStatsOverview(stats, user, maxWidth),

                          const SizedBox(height: 20),

                          // ===================================================
                          // 3. KAHOOT 360 INTERACTIVE BANNER
                          // ===================================================
                          _buildKahootBanner(maxWidth),

                          const SizedBox(height: 24),

                          // ===================================================
                          // 4. MAIN CONTENT AREA (Responsive Split / Stack)
                          // ===================================================
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column (flex: 7): Materi Modul
                                Expanded(
                                  flex: 7,
                                  child: _buildMateriSection(
                                    materiList,
                                    isWideScreen: true,
                                    maxWidth: maxWidth,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Right Column (flex: 5): Riwayat & Quick Tips
                                Expanded(
                                  flex: 5,
                                  child: _buildRiwayatSection(
                                    riwayatList,
                                    isWideScreen: true,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMateriSection(
                                  materiList,
                                  isWideScreen: false,
                                  maxWidth: maxWidth,
                                ),
                                const SizedBox(height: 24),
                                _buildRiwayatSection(
                                  riwayatList,
                                  isWideScreen: false,
                                ),
                              ],
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildTopHeader(Map<String, dynamic>? user, Map<String, dynamic>? stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 3),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFEFF6FF),
              backgroundImage: (user?['foto_profil'] != null &&
                      user!['foto_profil'].toString().isNotEmpty)
                  ? NetworkImage(user['foto_profil'] as String)
                  : null,
              child: (user?['foto_profil'] == null ||
                      user!['foto_profil'].toString().isEmpty)
                  ? const Icon(Icons.person, color: _blue, size: 24)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null && user['nama'] != null
                        ? 'Halo, ${user['nama']}! 👋'
                        : 'Halo, Siswa Arrava! 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Text(
                          'Jenjang ${user?['jenjang'] ?? 'SD'}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• Siap belajar?',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // XP Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, size: 15, color: Color(0xFFD97706)),
                const SizedBox(width: 3),
                Text(
                  '${user?['total_xp'] ?? stats?['total_xp'] ?? 0} XP',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Logout Button
          InkWell(
            onTap: () => showLogoutConfirmationDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFDC2626),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(
    Map<String, dynamic>? stats,
    Map<String, dynamic>? user,
    double maxWidth,
  ) {
    final kursusAktif = stats?['kursus_aktif'] ?? 0;
    final kuisLulus = stats?['kuis_lulus'] ?? 0;
    final totalQuiz = stats?['total_quiz'] ?? 0;
    final progressPercent = stats?['progress_percent'] ?? 0;
    final totalXp = user?['total_xp'] ?? stats?['total_xp'] ?? 0;

    final stat1 = _StatCard(
      icon: Icons.menu_book_rounded,
      color: _blue,
      bgColor: const Color(0xFFEFF6FF),
      value: '$kursusAktif',
      label: 'Modul Aktif',
      subtitle: 'Materi jenjang kamu',
    );

    final stat2 = _StatCard(
      icon: Icons.task_alt_rounded,
      color: _green,
      bgColor: const Color(0xFFECFDF5),
      value: '$progressPercent%',
      label: 'Kuis Lulus',
      subtitle: '$kuisLulus dari $totalQuiz kuis',
    );

    final stat3 = _StatCard(
      icon: Icons.emoji_events_rounded,
      color: _orange,
      bgColor: const Color(0xFFFEF3C7),
      value: '$totalXp',
      label: 'Total Poin XP',
      subtitle: 'Akumulasi skor kuis',
    );

    final stat4 = _StatCard(
      icon: Icons.local_fire_department_rounded,
      color: const Color(0xFFEF4444),
      bgColor: const Color(0xFFFEE2E2),
      value: 'Aktif',
      label: 'Status Belajar',
      subtitle: 'Konsisten & giat',
    );

    if (maxWidth >= 880) {
      return Row(
        children: [
          Expanded(child: stat1),
          const SizedBox(width: 12),
          Expanded(child: stat2),
          const SizedBox(width: 12),
          Expanded(child: stat3),
          const SizedBox(width: 12),
          Expanded(child: stat4),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: stat1),
        const SizedBox(width: 10),
        Expanded(child: stat2),
        const SizedBox(width: 10),
        Expanded(child: stat3),
      ],
    );
  }

  Widget _buildKahootBanner(double maxWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF4338CA), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⚡', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 5),
                      Text(
                        'MODE WAYGROUND & KAHOOT 360',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kuis Interaktif Pembelajaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Asah kemampuanmu dengan kuis seru berbatas waktu, raih skor sempurna, dan kumpulkan poin XP!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _currentIndex = 2),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text(
                    'Mulai Kerjakan Kuis ⚡',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (maxWidth >= 600) ...[
            const SizedBox(width: 20),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 44)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMateriSection(
    List<Map<String, dynamic>> materiList, {
    required bool isWideScreen,
    required double maxWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Materi Modul Pembelajaran',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _currentIndex = 1),
              icon: const Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _blue),
              ),
              label: const Icon(Icons.arrow_forward_rounded, size: 14, color: _blue),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (materiList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(Icons.menu_book_outlined, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                const Text(
                  'Belum ada modul materi tersedia',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideScreen ? 2 : (maxWidth < 500 ? 1 : 2),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 100,
            ),
            itemCount: materiList.length,
            itemBuilder: (context, index) {
              final materi = materiList[index];
              final colors = [_blue, _indigo, _green, _orange];
              final color = colors[index % colors.length];

              return _MateriCard(
                label: materi['judul_modul']?.toString() ?? 'Modul',
                subtitle: materi['tipe']?.toString() ?? 'Materi',
                jenjang: materi['jenjang']?.toString(),
                icon: Icons.menu_book_rounded,
                color: color,
                onTap: () => setState(() => _currentIndex = 1),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRiwayatSection(
    List<Map<String, dynamic>> riwayatList, {
    required bool isWideScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Belajar & Kuis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            if (riwayatList.isNotEmpty)
              Text(
                '${riwayatList.length} aktivitas',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (riwayatList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(Icons.quiz_outlined, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                const Text(
                  'Belum ada riwayat pengerjaan kuis',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selesaikan kuis untuk melihat skor dan XP yang kamu dapatkan di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: riwayatList.length,
            itemBuilder: (context, index) {
              final riwayat = riwayatList[index];
              final isLulus = riwayat['is_lulus'] == true;
              final color = isLulus ? _green : _orange;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RiwayatItem(
                  judul: riwayat['judul']?.toString() ?? 'Kuis Pembelajaran',
                  tanggal: riwayat['tanggal']?.toString() ?? 'Baru saja',
                  skor: '${riwayat['skor'] ?? 0}%',
                  icon: isLulus ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: color,
                  isLulus: isLulus,
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        // Kartu Tips Belajar Singkat
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_rounded, color: Color(0xFF2563EB), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kerjakan latihan kuis secara konsisten untuk memperdalam pemahaman materi dan meningkatkan XP kamu!',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF1E40AF),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1E5A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: _blue,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Belajar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              activeIcon: Icon(Icons.edit_rounded),
              label: 'Latihan / Kuis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-COMPONENTS
// =============================================================================

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.value,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MateriCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String? jenjang;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MateriCard({
    required this.label,
    required this.subtitle,
    this.jenjang,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        if (jenjang != null && jenjang!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              jenjang!,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiwayatItem extends StatelessWidget {
  final String judul;
  final String tanggal;
  final String skor;
  final IconData icon;
  final Color color;
  final bool isLulus;

  const _RiwayatItem({
    required this.judul,
    required this.tanggal,
    required this.skor,
    required this.icon,
    required this.color,
    required this.isLulus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tanggal,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLulus ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLulus ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  skor,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isLulus ? 'Lulus' : 'Coba Lagi',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
