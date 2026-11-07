import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/dashboard_service.dart';
import '../shared/utils/logout_dialog.dart';
import '../shared/widgets/samudra_hero_section.dart';
import '../shared/widgets/tween_float_background.dart';
import 'modules/student_module_list_page.dart';
import 'profile/student_profile_page.dart';
import 'profile/student_qr_sheet.dart';
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
        (_dashboardData?['materi_terbaru'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final riwayatList =
        (_dashboardData?['riwayat_belajar'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

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
                          // 1. TOP HEADER BAR: 'ARRAVA' & Log Out Saja
                          // ===================================================
                          _buildTopHeader(),

                          const SizedBox(height: 16),

                          // ===================================================
                          // 2. SAMUDRA HERO SECTION (Menimpa: Avatar, Nama, Bar EXP, Search Bar & Ikan Piksel)
                          // ===================================================
                          SamudraHeroSection(
                            user: user,
                            stats: stats,
                            onExploreTap: () {
                              setState(() => _currentIndex = 1);
                            },
                            onProfileTap: () {
                              setState(() => _currentIndex = 3);
                            },
                          ),

                          const SizedBox(height: 24),

                          // ===================================================
                          // 2. MAIN CONTENT AREA (Responsive Split / Stack)
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

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Teks Brand 'ARRAVA'
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ARRAVA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          // Tombol Logout
          InkWell(
            onTap: () => showLogoutConfirmationDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                ),
              ),
              label: const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: _blue,
              ),
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
                Icon(
                  Icons.menu_book_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
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
                Icon(
                  Icons.quiz_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
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
                  icon: isLulus
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
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

  Future<void> _showAttendanceQr() async {
    try {
      final profile = await DashboardService.fetchStudentProfile();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: const Color(0x9912233F),
        builder: (_) => StudentQrSheet(
          user: Map<String, dynamic>.from(profile['user'] as Map? ?? {}),
        ),
      );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat QR presensi. Silakan coba lagi.'),
          ),
        );
    }
  }

  Widget _buildBottomNav() {
    const blue = Color(0xFF007FBE);
    Widget item(int index, IconData icon, String label) => Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: _currentIndex == index ? blue : const Color(0xFF72839E),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _currentIndex == index
                      ? blue
                      : const Color(0xFF72839E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A007FBE),
            blurRadius: 20,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            item(0, Icons.home_outlined, 'Beranda'),
            item(1, Icons.menu_book_outlined, 'Belajar'),
            Expanded(
              child: InkWell(
                onTap: _showAttendanceQr,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        transform: Matrix4.translationValues(0, -8, 0),
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF339BFF), Color(0xFF14B9DC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x3D008FCC), blurRadius: 14),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Text(
                        'Presensi',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            item(2, Icons.edit_note_rounded, 'Latihan / Kuis'),
            item(3, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-COMPONENTS
// =============================================================================

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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Color(0xFF94A3B8),
              ),
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
              color: isLulus
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLulus
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFFDE68A),
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
