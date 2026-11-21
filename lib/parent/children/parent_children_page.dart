import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'parent_child_card.dart';

class ParentChildrenPage extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final int? selectedStudentId;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenMonitoring;

  const ParentChildrenPage({
    super.key,
    required this.children,
    required this.selectedStudentId,
    required this.onSelect,
    required this.onOpenMonitoring,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Anak Saya', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Pilih anak yang ingin Anda pantau.'),
        const SizedBox(height: 16),
        if (children.isEmpty) const ParentNoChildCard(),
        for (final student in children) ...[
          _buildStudentTile(student),
          const SizedBox(height: 10),
        ],
        if (selectedStudentId != null) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onOpenMonitoring,
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('Buka Monitoring'),
          ),
        ],
      ],
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    final id = int.tryParse(student['id_user'].toString());
    final isSelected = id != null && id == selectedStudentId;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        selected: isSelected,
        selectedTileColor: AppColors.primaryLight,
        leading: ParentChildAvatar(student: student),
        title: Text(student['nama']?.toString() ?? 'Ananda'),
        subtitle: Text(
          'Jenjang ${student['jenjang'] ?? '-'} • NISN ${student['nisn'] ?? '-'}',
        ),
        trailing: Icon(
          isSelected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
        ),
        onTap: id == null || isSelected ? null : () => onSelect(id),
      ),
    );
  }
}
