import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import 'teacher_detail_page.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  int _selectedFilter = 0;

  final List<String> _filters = [
    'Semua',
    'Wali Kelas',
    'Guru Mapel',
    'Guru BK',
  ];

  final List<_TeacherData> _teachers = [
    _TeacherData(
      name: 'Drs. Bambang Haryanto, M.',
      nip: '19750812 199903 1004',
      subject: 'Matematika Wajib & Peminatan',
      role: 'Wali Kelas XII-IPA 1',
      status: 'Aktif',
      initials: 'BH',
    ),
    _TeacherData(
      name: 'Siti Nurhaliza, S.Kom., M.T.',
      nip: '19880415 201402 2 003',
      subject: 'Informatika & Pemrograman Web',
      role: 'Guru Mapel',
      status: 'Aktif',
      initials: 'SN',
    ),
    _TeacherData(
      name: 'Ahmad Fauzi, S.Pd.',
      nip: '19910220 201801 1 007',
      subject: 'Bahasa Inggris & Komunikasi Bisnis',
      role: 'Wali Kelas XI-IPS 2',
      status: 'Aktif',
      initials: 'AF',
    ),
    _TeacherData(
      name: 'Ratna Kusuma Dewi, S.Psi.',
      nip: '19851109 201012 2 005',
      subject: 'Bimbingan Konseling (BK)',
      role: 'Guru BK Tingkat Akhir',
      status: 'Aktif',
      initials: 'RK',
    ),
    _TeacherData(
      name: 'Hendro Wijaya, M.Si.',
      nip: '19790623 200501 1 002',
      subject: 'Fisika Terapan',
      role: 'Guru Mapel',
      status: 'Cuti',
      initials: 'HW',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppHeader(title: 'Manajemen Guru', onNotificationTap: () {}),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageTitle(),

                  const SizedBox(height: 18),

                  _buildStatistics(),

                  const SizedBox(height: 20),

                  _buildSearchField(),

                  const SizedBox(height: 10),

                  _buildFilters(),

                  const SizedBox(height: 18),

                  ..._getFilteredTeachers().map(
                    (teacher) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildTeacherCard(teacher),
                    ),
                  ),

                  const SizedBox(height: 6),

                  _buildLoadMore(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  Widget _buildPageTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Guru',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kelola tenaga pendidik & staf\npengajar (28 Guru Aktif)',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        ElevatedButton.icon(
          onPressed: () {
            // TODO: Tambah guru
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Guru',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(102, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.groups_outlined,
            iconBackground: AppColors.primaryLight,
            iconColor: AppColors.primary,
            value: '32',
            label: 'Total Guru',
            badge: '+2 bln ini',
            badgeColor: const Color(0xFFE5EAF8),
            badgeTextColor: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.verified_outlined,
            iconBackground: const Color(0xFFD9FBEA),
            iconColor: AppColors.success,
            value: '28',
            label: 'Guru Aktif',
            badge: '92% Mengajar',
            badgeColor: const Color(0xFF63E6B2),
            badgeTextColor: const Color(0xFF006B4A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String value,
    required String label,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Container(
      height: 122,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari nama atau NIP guru...',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 21,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilters() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedFilter == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: selected ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TEACHER CARD
  // ============================================================

  Widget _buildTeacherCard(_TeacherData teacher) {
    final bool active = teacher.status == 'Aktif';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherDetailPage(
              name: teacher.name,
              nip: teacher.nip,
              subject: teacher.subject,
              role: teacher.role,
              status: teacher.status,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(teacher),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              teacher.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          _buildStatus(teacher.status),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'NIP: ${teacher.nip}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Flexible(child: _buildTag(teacher.subject, primary: true)),

                const SizedBox(width: 7),

                Flexible(child: _buildTag(teacher.role, primary: false)),
              ],
            ),

            const SizedBox(height: 13),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     _buildActionButton(
            //       icon: Icons.edit_outlined,
            //       background: AppColors.primaryLight,
            //       foreground: AppColors.primary,
            //       onTap: () {
            //         // TODO: Edit guru
            //       },
            //     ),

            //     const SizedBox(width: 7),

            //     _buildActionButton(
            //       icon: Icons.delete_outline,
            //       background: const Color(0xFFFFD9D5),
            //       foreground: AppColors.error,
            //       onTap: () {
            //         // TODO: Hapus guru
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(_TeacherData teacher) {
    return Container(
      width: 57,
      height: 57,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        teacher.initials,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    final bool active = status == 'Aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF63E6B2) : const Color(0xFFE5EAF3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF00875A) : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF006B4A) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {required bool primary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: primary ? AppColors.primaryLight : const Color(0xFFE5EAF3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9,
          color: primary ? AppColors.primaryDark : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 46,
          height: 42,
          child: Icon(icon, size: 19, color: foreground),
        ),
      ),
    );
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Widget _buildLoadMore() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Load more
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Muat Lebih Banyak',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 7),
            Icon(Icons.keyboard_arrow_down, size: 19),
          ],
        ),
      ),
    );
  }

  List<_TeacherData> _getFilteredTeachers() {
    if (_selectedFilter == 0) {
      return _teachers;
    }

    final filter = _filters[_selectedFilter];

    return _teachers.where((teacher) {
      return teacher.role == filter;
    }).toList();
  }
}

class _TeacherData {
  final String name;
  final String nip;
  final String subject;
  final String role;
  final String status;
  final String initials;

  const _TeacherData({
    required this.name,
    required this.nip,
    required this.subject,
    required this.role,
    required this.status,
    required this.initials,
  });
}
