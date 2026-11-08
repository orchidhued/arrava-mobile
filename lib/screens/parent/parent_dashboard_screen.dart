import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../providers/notification_provider.dart';
import '../../services/dashboard_service.dart';
import '../../shared/utils/logout_dialog.dart';
import '../../shared/widgets/notification_sheet.dart';
import '../modules/student_module_list_page.dart';
import '../quizzes/student_quiz_list_page.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _parentName = 'Orang Tua / Wali';
  String _parentEmail = '';
  final String _parentStatus = 'Aktif';

  Map<String, dynamic>? _dashboardData;
  int? _selectedStudentId;

  static const Color _primary = AppColors.primary;
  static const Color _indigo = AppColors.primaryDark;

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData({int? studentId}) async {
    try {
      context.read<NotificationProvider>().fetchNotifications(silent: true);
      final name = await SecureStorage.read('user_name');
      final email = await SecureStorage.read('user_email');
      if (mounted) {
        setState(() {
          if (name != null && name.trim().isNotEmpty) {
            _parentName = name.trim();
          }
          if (email != null && email.trim().isNotEmpty) {
            _parentEmail = email.trim();
          }
        });
      }

      final data = await DashboardService.fetchParentDashboard(
        studentId: studentId ?? _selectedStudentId,
      );

      if (mounted) {
        setState(() {
          _dashboardData = data;
          if (data['selected_student'] != null) {
            _selectedStudentId = int.tryParse(
              data['selected_student']['id_user']?.toString() ?? '',
            );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildCurrentTab(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: StudentModuleListPage(),
        );
      case 2:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: StudentQuizListPage(),
        );
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final children = (_dashboardData?['children'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final selectedStudent = _dashboardData?['selected_student'] as Map<String, dynamic>?;
    final stats = _dashboardData?['stats'] as Map<String, dynamic>?;
    final activities = (_dashboardData?['recent_activities'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final achievements = (_dashboardData?['achievements'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadParentData(studentId: _selectedStudentId),
        color: _primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER: Profil & Logout
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
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
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDF3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.family_restroom_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _parentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF3FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Orang Tua',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Consumer<NotificationProvider>(
                    builder: (context, notifProv, _) {
                      final unread = notifProv.unreadCount;
                      return GestureDetector(
                        onTap: () => NotificationSheet.show(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFB2E7FC),
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                              if (unread > 0)
                                Positioned(
                                  top: 3,
                                  right: 3,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => showLogoutConfirmationDialog(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEE),
                        shape: BoxShape.circle,
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
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. CHILD SELECTOR / STATUS CARD
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: _primary),
                  ),
                )
              else if (children.isNotEmpty)
                _buildChildSelectorCard(children, selectedStudent)
              else
                _buildNoChildCard(),

              const SizedBox(height: 18),

              // 3. STATS MONITORING ANANDA (LIVE METRICS)
              if (stats != null && selectedStudent != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Perkembangan Belajar Ananda',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (stats['avg_nilai'] ?? 0) >= (stats['kkm'] ?? 75)
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (stats['avg_nilai'] ?? 0) >= (stats['kkm'] ?? 75)
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFDE68A),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        stats['status_eval']?.toString() ?? 'Tuntas',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: (stats['avg_nilai'] ?? 0) >= (stats['kkm'] ?? 75)
                              ? const Color(0xFF059669)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatsGrid(stats),
                const SizedBox(height: 22),
              ],

              // 4. RIWAYAT KUIS TERBARU ANANDA
              if (activities.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Evaluasi & Kuis Ananda',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${activities.length} aktivitas',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...activities.map((a) => _buildActivityItem(a)),
                const SizedBox(height: 22),
              ],

              // 5. PENCAPAIAN & LENCANA ANANDA
              if (achievements.isNotEmpty) ...[
                Text(
                  'Pencapaian & Lencana Prestasi',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ...achievements.map((p) => _buildAchievementItem(p)),
                const SizedBox(height: 22),
              ],

              // 6. HERO BANNER PORTAL ORANG TUA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00628E), Color(0xFF007FBE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00628E), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFB2E7FC),
                      offset: Offset(0, 5),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🛡️ PORTAL PENDAMPINGAN',
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '● Aktif',
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dampingi Proses Belajar Ananda',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pantau modul pembelajaran, pengerjaan kuis, dan pencapaian prestasi putra-putri Anda secara transparan dan terintegrasi.',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 7. LAYANAN MONITORING GRID
              Text(
                'Layanan Monitoring Belajar',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  final double w = constraints.maxWidth;
                  final int cols = w >= 600 ? 4 : 2;

                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: cols == 2 ? 1.35 : 1.2,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                        title: 'Materi Modul',
                        subtitle: 'Akses modul & bahan ajar ananda',
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      _buildFeatureCard(
                        icon: Icons.quiz_rounded,
                        color: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFF5F3FF),
                        title: 'Kuis & Nilai',
                        subtitle: 'Daftar latihan & evaluasi kuis',
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                      _buildFeatureCard(
                        icon: Icons.emoji_events_rounded,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        title: 'Pencapaian',
                        subtitle: 'Lencana prestasi & poin XP',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pencapaian ananda tersinkronisasi otomatis dari pengerjaan kuis.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.qr_code_scanner_rounded,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                        title: 'Presensi QR',
                        subtitle: 'Kehadiran harian tercatat',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Presensi dilakukan oleh ananda di sekolah menggunakan scan QR.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              // 8. TIPS PENDAMPINGAN ORANG TUA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tips Pendampingan Belajar di Rumah',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTipItem('1. Luangkan 15-20 menit sehari untuk mereview materi dan kuis bersama anak.'),
                    _buildTipItem('2. Berikan apresiasi saat anak berhasil menyelesaikan latihan soal dan meraih lencana baru.'),
                    _buildTipItem('3. Jika ada materi yang belum tuntas, bantu ananda mengulang video pembelajaran pada tab Materi.'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET HELPER BUILDERS
  // ===========================================================================

  Widget _buildChildSelectorCard(
    List<Map<String, dynamic>> children,
    Map<String, dynamic>? selectedStudent,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
              const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Siswa yang Dipantau',
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (children.length > 1)
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedStudentId,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                    items: children.map((c) {
                      final id = int.tryParse(c['id_user']?.toString() ?? '') ?? 0;
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text(
                          c['nama']?.toString() ?? 'Anak',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newId) {
                      if (newId != null && newId != _selectedStudentId) {
                        setState(() {
                          _selectedStudentId = newId;
                          _isLoading = true;
                        });
                        _loadParentData(studentId: newId);
                      }
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDF3FF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    selectedStudent?['nama']?.toString().isNotEmpty == true
                        ? selectedStudent!['nama'].toString().substring(0, 1).toUpperCase()
                        : 'A',
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedStudent?['nama']?.toString() ?? 'Ananda',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Jenjang ${selectedStudent?['jenjang'] ?? 'SD'} • NISN: ${selectedStudent?['nisn'] ?? '-'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 3),
                    Text(
                      '${selectedStudent?['total_poin'] ?? 0} XP',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoChildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFEF3C7),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 32),
          const SizedBox(height: 8),
          Text(
            'Belum Ada Akun Siswa Terhubung',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Silakan hubungi pihak sekolah untuk menautkan akun ananda dengan akun Orang Tua Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              color: Colors.brown.shade600,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final int cols = w >= 600 ? 4 : 2;

        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: cols == 2 ? 1.6 : 1.4,
          children: [
            _buildStatCard(
              title: 'Nilai Rata-Rata',
              value: '${stats['avg_nilai'] ?? 0}%',
              subtitle: 'KKM Minimal: ${stats['kkm'] ?? 75}',
              icon: Icons.analytics_rounded,
              color: AppColors.primary,
              bgColor: const Color(0xFFDDF3FF),
            ),
            _buildStatCard(
              title: 'Total Akumulasi',
              value: '${stats['total_poin'] ?? 0} XP',
              subtitle: 'Poin hasil belajar',
              icon: Icons.bolt_rounded,
              color: const Color(0xFFD97706),
              bgColor: const Color(0xFFFEF3C7),
            ),
            _buildStatCard(
              title: 'Modul Tuntas',
              value: '${stats['modul_selesai'] ?? 0} Modul',
              subtitle: 'Dari ${stats['total_modul'] ?? 0} materi',
              icon: Icons.task_alt_rounded,
              color: const Color(0xFF059669),
              bgColor: const Color(0xFFD1FAE5),
            ),
            _buildStatCard(
              title: 'Peringkat Kelas',
              value: stats['rank_kelas'] != null && stats['rank_kelas'] != '-'
                  ? '#${stats['rank_kelas']}'
                  : '-',
              subtitle: 'Tingkat jenjang',
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFF00628E),
              bgColor: const Color(0xFFDDF3FF),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunitoSans(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> a) {
    final bool isLulus = a['is_lulus'] == true;
    final color = isLulus ? const Color(0xFF059669) : const Color(0xFFD97706);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow3D,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLulus ? Icons.check_circle_rounded : Icons.history_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['judul']?.toString() ?? 'Kuis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${a['tanggal']} • ${a['skor']}',
                  style: GoogleFonts.nunitoSans(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${a['nilai']}%',
              style: GoogleFonts.nunitoSans(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFEF3C7),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['judul']?.toString() ?? 'Prestasi Belajar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: const Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p['deskripsi']?.toString() ?? 'Diraih oleh ananda',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          Text(
            p['tanggal']?.toString() ?? '',
            style: GoogleFonts.nunitoSans(
              fontSize: 10.5,
              color: const Color(0xFFB45309),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.nunitoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    width: 76,
                    height: 76,
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
                        Icons.family_restroom_rounded,
                        size: 38,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _parentName,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _parentEmail.isNotEmpty ? _parentEmail : 'Akun Orang Tua Terverifikasi',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 5),
                        Text(
                          'Status Akun: $_parentStatus',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11.5,
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

            const SizedBox(height: 18),

            // Opsi & Pengaturan
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
                    title: Text(
                      'Peran Akun',
                      style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    trailing: Text(
                      'Orang Tua / Wali Siswa',
                      style: GoogleFonts.nunitoSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE8F3FF)),
                  FutureBuilder<bool>(
                    future: PreferencesService.isSoundEnabled(),
                    builder: (context, snap) {
                      final val = snap.data ?? true;
                      return SwitchListTile(
                        secondary: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                        title: Text(
                          'Efek Suara Kuis',
                          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Bunyi audio pada pratinjau kuis',
                          style: GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        value: val,
                        onChanged: (newVal) async {
                          await PreferencesService.setSoundEnabled(newVal);
                          setState(() {});
                        },
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE8F3FF)),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                    title: Text(
                      'Versi Aplikasi',
                      style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    trailing: Text(
                      '1.0.0 (Portal Orang Tua)',
                      style: GoogleFonts.nunitoSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => showLogoutConfirmationDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'Keluar dari Akun',
                  style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFECEE),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    Widget item(int index, IconData icon, IconData activeIcon, String label) {
      final isSelected = _currentIndex == index;
      const activeColor = AppColors.primary;
      const inactiveColor = Color(0xFF72839E);

      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFDDF3FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
        border: Border(
          top: BorderSide(color: Color(0xFFE2F0FD), width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              item(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
              item(1, Icons.menu_book_outlined, Icons.menu_book_rounded, 'Materi'),
              item(2, Icons.quiz_outlined, Icons.quiz_rounded, 'Kuis'),
              item(3, Icons.person_outline_rounded, Icons.person_rounded, 'Akun'),
            ],
          ),
        ),
      ),
    );
  }
}
