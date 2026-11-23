import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';

class ParentChildCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback? onChange;

  const ParentChildCard({super.key, required this.student, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ParentChildAvatar(student: student),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['nama']?.toString() ?? 'Ananda',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Jenjang ${student['jenjang'] ?? '-'} • NISN ${student['nisn'] ?? '-'}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (onChange != null)
              TextButton.icon(
                onPressed: onChange,
                icon: const Icon(Icons.swap_horiz_rounded, size: 19),
                label: const Text('Ubah'),
              ),
          ],
        ),
      ),
    );
  }
}

class ParentChildAvatar extends StatelessWidget {
  final Map<String, dynamic> student;

  const ParentChildAvatar({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final photoUrl = ApiConstants.resolveMediaUrl(
      student['foto_profil']?.toString(),
    );
    final name = student['nama']?.toString().trim() ?? '';
    return CircleAvatar(
      radius: 23,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primary,
      foregroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
      onForegroundImageError: photoUrl == null ? null : (error, stackTrace) {},
      child: Text(name.isEmpty ? 'A' : name.characters.first.toUpperCase()),
    );
  }
}

class ParentNoChildCard extends StatelessWidget {
  const ParentNoChildCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.info_outline_rounded, color: AppColors.warning),
        title: Text('Belum ada akun siswa terhubung'),
        subtitle: Text('Hubungi pihak sekolah untuk menautkan akun anak.'),
      ),
    );
  }
}
