import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum ParentMonitoringMenu {
  grades(
    'Perkembangan Nilai',
    'Lihat hasil dan perkembangan nilai.',
    Icons.trending_up_rounded,
    AppColors.primaryDark,
    AppColors.primaryLight,
  ),
  materials(
    'Materi Belajar',
    'Pantau ketuntasan materi anak.',
    Icons.menu_book_rounded,
    AppColors.success,
    Color(0xFFD1FAE5),
  ),
  quizzes(
    'Riwayat Kuis',
    'Lihat hasil kuis yang dikerjakan.',
    Icons.assignment_rounded,
    Color(0xFFB45309),
    Color(0xFFFEF3C7),
  ),
  achievements(
    'Pencapaian',
    'Lihat prestasi dan penghargaan.',
    Icons.emoji_events_rounded,
    Color(0xFF7C3AED),
    Color(0xFFF3E8FF),
  ),
  activities(
    'Aktivitas Belajar',
    'Pantau aktivitas belajar terbaru.',
    Icons.timeline_rounded,
    AppColors.primary,
    AppColors.primaryLight,
  ),
  attendance(
    'Absensi',
    'Lihat pemberitahuan presensi anak.',
    Icons.event_available_rounded,
    Color(0xFFC2410C),
    Color(0xFFFFEDD5),
  );

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color background;

  const ParentMonitoringMenu(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.background,
  );
}
