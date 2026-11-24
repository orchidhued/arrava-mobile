import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../monitoring/parent_monitoring_menu.dart';
import '../widgets/parent_feature_card.dart';
import '../widgets/parent_result_cards.dart';

class ParentHomePage extends StatelessWidget {
  final String parentName;
  final Widget childCard;
  final Map<String, dynamic>? selectedStudent;
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> activities;
  final List<Map<String, dynamic>> achievements;
  final ValueChanged<ParentMonitoringMenu> onOpenMonitoring;

  const ParentHomePage({
    super.key,
    required this.parentName,
    required this.childCard,
    required this.selectedStudent,
    required this.stats,
    required this.activities,
    required this.achievements,
    required this.onOpenMonitoring,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang, $parentName',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        childCard,
        const SizedBox(height: 18),
        // 3. STATS MONITORING ANANDA (LIVE METRICS)
        if (selectedStudent != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Perkembangan Belajar Ananda',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
              Expanded(
                child: Text(
                  'Riwayat Evaluasi & Kuis Ananda',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
          ...activities.map((a) => ParentActivityCard(activity: a)),
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
          ...achievements.map((p) => ParentAchievementCard(achievement: p)),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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

        ParentFeatureGrid(
          maxColumns: 4,
          children: [
            ParentFeatureCard(
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              title: 'Materi Modul',
              subtitle: 'Akses modul & bahan ajar ananda',
              onTap: selectedStudent == null
                  ? null
                  : () => onOpenMonitoring(ParentMonitoringMenu.materials),
            ),
            ParentFeatureCard(
              icon: Icons.quiz_rounded,
              color: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF5F3FF),
              title: 'Kuis & Nilai',
              subtitle: 'Daftar latihan & evaluasi kuis',
              onTap: selectedStudent == null
                  ? null
                  : () => onOpenMonitoring(ParentMonitoringMenu.quizzes),
            ),
            ParentFeatureCard(
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFD97706),
              bgColor: const Color(0xFFFEF3C7),
              title: 'Pencapaian',
              subtitle: 'Lencana prestasi & poin XP',
              onTap: selectedStudent == null
                  ? null
                  : () => onOpenMonitoring(ParentMonitoringMenu.achievements),
            ),
            ParentFeatureCard(
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF059669),
              bgColor: const Color(0xFFECFDF5),
              title: 'Absensi',
              subtitle: 'Pemberitahuan presensi anak',
              onTap: selectedStudent == null
                  ? null
                  : () => onOpenMonitoring(ParentMonitoringMenu.attendance),
            ),
          ],
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
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tips Pendampingan Belajar di Rumah',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTipItem(
                '1. Luangkan 15-20 menit sehari untuk mereview materi dan kuis bersama anak.',
              ),
              _buildTipItem(
                '2. Berikan apresiasi saat anak berhasil menyelesaikan latihan soal dan meraih lencana baru.',
              ),
              _buildTipItem(
                '3. Jika ada materi yang belum tuntas, bantu ananda mengulang video pembelajaran di menu Materi Belajar.',
              ),
            ],
          ),
        ),
      ],
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
          mainAxisExtent: 120 * MediaQuery.textScalerOf(context).scale(1),
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
}
