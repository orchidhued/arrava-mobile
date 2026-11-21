import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/parent_feature_card.dart';
import 'parent_monitoring_menu.dart';

class ParentMonitoringPage extends StatelessWidget {
  final Widget childCard;
  final Map<String, dynamic>? student;
  final Map<String, dynamic> stats;
  final ValueChanged<ParentMonitoringMenu> onOpenMenu;

  const ParentMonitoringPage({
    super.key,
    required this.childCard,
    required this.student,
    required this.stats,
    required this.onOpenMenu,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completed = (stats['modul_selesai'] as num?)?.toInt() ?? 0;
    final total = (stats['total_modul'] as num?)?.toInt() ?? 0;
    final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final quizCount = (stats['total_quiz_dikerjakan'] as num?)?.toInt() ?? 0;
    final metrics = <ParentMonitoringMenu, String>{
      if (quizCount > 0)
        ParentMonitoringMenu.grades: 'Rata-rata ${stats['avg_nilai']}',
      ParentMonitoringMenu.materials: '$completed/$total selesai',
      ParentMonitoringMenu.quizzes: '$quizCount hasil',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Monitoring Belajar',
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Pantau aktivitas dan perkembangan belajar anak.'),
        const SizedBox(height: 16),
        childCard,
        if (student != null) ...[
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFFEDF3FF),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ketuntasan Belajar',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              total > 0
                                  ? '$completed dari $total modul telah tuntas.'
                                  : 'Belum ada modul tersedia.',
                            ),
                          ],
                        ),
                      ),
                      if (total > 0) ...[
                        const SizedBox(width: 12),
                        SizedBox.square(
                          dimension: 48,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: AppColors.primaryLight,
                                semanticsLabel: 'Ketuntasan modul',
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${(progress * 100).round()}%',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: AppColors.primaryLight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Menu Monitoring',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ParentFeatureGrid(
            children: [
              for (final menu in ParentMonitoringMenu.values)
                ParentFeatureCard(
                  icon: menu.icon,
                  color: menu.color,
                  bgColor: menu.background,
                  title: menu.title,
                  subtitle: menu.description,
                  metric: metrics[menu],
                  showArrow: true,
                  onTap: () => onOpenMenu(menu),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Card(
            color: Color(0xFFEDF3FF),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.sentiment_satisfied_alt_rounded),
              ),
              title: Text('Perhatian Orang Tua Sangat Berharga'),
              subtitle: Text(
                'Berikan pujian kecil atas usaha belajarnya hari ini.',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
