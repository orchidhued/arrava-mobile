import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../widgets/parent_result_cards.dart';
import 'parent_materials_list.dart';
import 'parent_monitoring_menu.dart';

class ParentMonitoringDetail extends StatelessWidget {
  final ParentMonitoringMenu menu;
  final Map<String, dynamic> student;
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> activities;
  final List<Map<String, dynamic>> achievements;
  final VoidCallback onBack;

  const ParentMonitoringDetail({
    super.key,
    required this.menu,
    required this.student,
    required this.stats,
    required this.activities,
    required this.achievements,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Monitoring'),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          menu.title,
          style: theme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        Text(student['nama']?.toString() ?? 'Ananda'),
        const SizedBox(height: 16),
        ..._buildContent(context),
      ],
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    switch (menu) {
      case ParentMonitoringMenu.grades:
        final quizCount = (stats['total_quiz_dikerjakan'] as num?) ?? 0;
        return [
          Card(
            child: ListTile(
              leading: Icon(menu.icon, color: menu.color),
              title: Text(
                quizCount == 0
                    ? 'Belum ada nilai'
                    : "Rata-rata ${stats['avg_nilai']}%",
              ),
              subtitle: Text(
                "KKM ${stats['kkm'] ?? 75}"
                "${quizCount == 0 ? '' : " • ${stats['status_eval'] ?? ''}"}",
              ),
            ),
          ),
          if (activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Nilai terbaru'),
            const SizedBox(height: 8),
            for (final activity in activities)
              ParentActivityCard(activity: activity),
          ],
        ];
      case ParentMonitoringMenu.materials:
        return [
          Card(
            child: ListTile(
              leading: Icon(menu.icon, color: menu.color),
              title: Text(
                "${stats['modul_selesai'] ?? 0} dari ${stats['total_modul'] ?? 0} modul tuntas",
              ),
              subtitle: const Text('Ringkasan ketuntasan anak'),
            ),
          ),
          const SizedBox(height: 16),
          ParentMaterialsList(
            jenjangId: int.tryParse(student['id_jenjang']?.toString() ?? ''),
          ),
        ];
      case ParentMonitoringMenu.quizzes:
      case ParentMonitoringMenu.activities:
        return [
          if (activities.isEmpty)
            const Card(child: ListTile(title: Text('Belum ada hasil kuis.')))
          else ...[
            const Text('Hasil kuis terbaru'),
            const SizedBox(height: 8),
            for (final activity in activities)
              ParentActivityCard(activity: activity),
          ],
        ];
      case ParentMonitoringMenu.achievements:
        return [
          if (achievements.isEmpty)
            const Card(child: ListTile(title: Text('Belum ada pencapaian.'))),
          for (final achievement in achievements)
            ParentAchievementCard(achievement: achievement),
        ];
      case ParentMonitoringMenu.attendance:
        final provider = context.watch<NotificationProvider>();
        final childId = int.tryParse(student['id_user']?.toString() ?? '');
        final notifications = provider.notifications.where(
          (item) => childId != null && item.anakId == childId,
        );
        return [
          const Text('Pemberitahuan presensi terbaru'),
          const SizedBox(height: 10),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null)
            Card(
              child: ListTile(
                title: const Text('Pemberitahuan gagal dimuat.'),
                trailing: TextButton(
                  onPressed: () => provider.fetchNotifications(),
                  child: const Text('Coba lagi'),
                ),
              ),
            )
          else if (notifications.isEmpty)
            const Card(
              child: ListTile(title: Text('Belum ada pemberitahuan presensi.')),
            )
          else
            for (final item in notifications)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      item.tipe == 'danger'
                          ? Icons.event_busy_rounded
                          : Icons.event_available_rounded,
                      color: item.tipe == 'danger'
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                    title: Text(item.judul),
                    subtitle: Text('${item.pesan}\n${item.waktu}'),
                  ),
                ),
              ),
        ];
    }
  }
}
