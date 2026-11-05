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

  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _purple = Color(0xFF8B5CF6);

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
        body: const StudentModuleListPage(),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    if (_currentIndex == 2) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const StudentQuizListPage(),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    if (_currentIndex == 3) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const StudentProfilePage(),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    final user = _dashboardData?['user'] as Map<String, dynamic>?;
    final stats = _dashboardData?['stats'] as Map<String, dynamic>?;
    final materiList = (_dashboardData?['materi_terbaru'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final riwayatList = (_dashboardData?['riwayat_belajar'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TweenFloatBackground(
        scrollController: _scrollController,
        child: SafeArea(
          child: RefreshIndicator(
            color: _blue,
            onRefresh: _loadDashboard,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                final bool isWide = maxWidth >= 850;

                if (_isLoading && _dashboardData == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: _blue),
                    ),
                  );
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 24 : (screenWidth * 0.05).clamp(16.0, 24.0),
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1140),
                      child: isWide
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(user, true),
                                const SizedBox(height: 22),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sisi Kiri (60%): Banner Utama & Materi Modul
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildInteractiveBanner(),
                                          const SizedBox(height: 24),
                                          _buildMateriSection(materiList, isWide: true),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Sisi Kanan (40%): Ringkasan Metrik & Riwayat Kuis
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildStatsCards(stats, user),
                                          const SizedBox(height: 24),
                                          _buildRiwayatSection(riwayatList),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(user, false),
                                const SizedBox(height: 18),
                                _buildStatsCards(stats, user),
                                const SizedBox(height: 18),
                                _buildInteractiveBanner(),
                                const SizedBox(height: 22),
                                _buildMateriSection(materiList, isWide: false),
                                const SizedBox(height: 22),
                                _buildRiwayatSection(riwayatList),
                                const SizedBox(height: 16),
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

  Widget _buildHeader(Map<String, dynamic>? user, bool isWide) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _currentIndex = 3),
          child: CircleAvatar(
            radius: isWide ? 26 : 22,
            backgroundColor: const Color(0xFFDCE3FF),
            backgroundImage: (user?['foto_profil'] != null &&
                    user!['foto_profil'].toString().isNotEmpty)
                ? NetworkImage(user['foto_profil'] as String)
                : null,
            child: (user?['foto_profil'] == null ||
                    user!['foto_profil'].toString().isEmpty)
                ? const Icon(Icons.person, color: _blue)
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
                  style: TextStyle(
                    fontSize: isWide ? 19 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B2A6B),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user != null && user['jenjang'] != null
                      ? 'Jenjang ${user['jenjang']} • Siap belajar hari ini?'
                      : 'Siap belajar apa hari ini?',
                  style: const TextStyle(
                    color: Color(0xFF3A5AA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: _green, size: 16),
              const SizedBox(width: 4),
              Text(
                '${user?['total_xp'] ?? 0} XP',
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => showLogoutConfirmationDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFEF4444),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(Map<String, dynamic>? stats, Map<String, dynamic>? user) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${stats?['kursus_aktif'] ?? 0}',
            label: 'Modul Aktif',
            color: _blue,
            icon: Icons.menu_book_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${stats?['progress_percent'] ?? 0}%',
            label: 'Kuis Lulus',
            color: _green,
            icon: Icons.verified_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${user?['total_xp'] ?? stats?['total_xp'] ?? 0}',
            label: 'Total XP',
            color: _orange,
            icon: Icons.stars_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveBanner() {
    return InkWell(
      onTap: () => setState(() => _currentIndex = 2),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF312E81), Color(0xFF1E40AF), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Text('⚡', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Kuis Interaktif 360',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 16),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Asah kemampuanmu dan raih poin XP kelulusan!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mulai',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriSection(List<Map<String, dynamic>> materiList, {bool isWide = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Materi Modul Pembelajaran',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF0B2A6B),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: _blue,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (materiList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Icon(Icons.menu_book_outlined, size: 36, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Belum ada modul materi tersedia',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              // Di desktop kolom kiri: 2 kolom. Di tablet/HP: 2 kolom jika >=400, 1 kolom jika <400
              final int cols = constraints.maxWidth < 420 ? 1 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 74,
                ),
                itemCount: materiList.length,
                itemBuilder: (context, index) {
                  final materi = materiList[index];
                  final colors = [_blue, _purple, _green, _orange];
                  final color = colors[index % colors.length];

                  return _MateriCard(
                    label: materi['judul_modul']?.toString() ?? 'Modul',
                    subtitle: materi['tipe']?.toString() ?? 'Materi Pembelajaran',
                    icon: Icons.menu_book_rounded,
                    color: color,
                    onTap: () => setState(() => _currentIndex = 1),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildRiwayatSection(List<Map<String, dynamic>> riwayatList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Belajar & Kuis',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF0B2A6B),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 2),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: _blue,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Daftar Kuis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (riwayatList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Icon(Icons.quiz_outlined, size: 36, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Belum ada riwayat pengerjaan kuis',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selesaikan kuis untuk melihat riwayat dan XP yang didapat di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
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
                padding: EdgeInsets.only(
                  bottom: index == riwayatList.length - 1 ? 0 : 10,
                ),
                child: _RiwayatItem(
                  judul: riwayat['judul']?.toString() ?? 'Kuis Pembelajaran',
                  tanggal: riwayat['tanggal']?.toString() ?? 'Baru saja',
                  skor: '${riwayat['skor'] ?? 0}%',
                  icon: isLulus ? Icons.check_circle_outline : Icons.history,
                  color: color,
                ),
              );
            },
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              currentIndex: _currentIndex,
              selectedItemColor: _blue,
              unselectedItemColor: Colors.grey,
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
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 105;

          if (isNarrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

  const _RiwayatItem({
    required this.judul,
    required this.tanggal,
    required this.skor,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              color: color.withValues(alpha: 0.12),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(
              skor,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
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
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MateriCard({
    required this.label,
    required this.subtitle,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
