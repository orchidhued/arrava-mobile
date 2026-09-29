import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  int _selectedFilter = 0;

  final List<String> _filters = ['Semua', 'SD', 'SMP', 'SMA'];

  final List<_StudentData> _students = [
    _StudentData(
      name: 'Muhammad Rizky Pratama',
      nisn: '0068192301',
      className: 'XII-IPA 1',
      classLabel: '12 IPA 1',
      initials: 'MR',
      status: 'Aktif',
      image: 'assets/images/students/rizky.jpg',
    ),
    _StudentData(
      name: 'Siti Aisyah Rahmadani',
      nisn: '0074819204',
      className: 'XI-RPL 2',
      classLabel: '11 RPL',
      initials: 'SA',
      status: 'Aktif',
      image: 'assets/images/students/aisyah.jpg',
    ),
    _StudentData(
      name: 'Bima Arya Wijaya',
      nisn: '0081290382',
      className: 'X-MIPA 3',
      classLabel: '10 MIPA',
      initials: 'BA',
      status: 'Aktif',
      image: 'assets/images/students/bima.jpg',
    ),
    _StudentData(
      name: 'Nabila Putri Maharani',
      nisn: '0069912048',
      className: 'XII-IPS 1',
      classLabel: '12 IPS 1',
      initials: 'NP',
      status: 'Aktif',
    ),
    _StudentData(
      name: 'Farhan Maulana',
      nisn: '0057218399',
      className: 'XII-IPA 2',
      classLabel: '12 IPA 2',
      initials: 'FM',
      status: 'Aktif',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final students = _getFilteredStudents();

    return SafeArea(
      child: Column(
        children: [
          AppHeader(title: 'Manajemen Siswa', onNotificationTap: () {}),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageTitle(),

                  const SizedBox(height: 18),

                  _buildSearch(),

                  const SizedBox(height: 10),

                  _buildFilters(),

                  const SizedBox(height: 18),

                  _buildStatistics(),

                  const SizedBox(height: 22),

                  _buildListHeader(students.length),

                  const SizedBox(height: 10),

                  ...students.map(
                    (student) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildStudentCard(student),
                    ),
                  ),

                  const SizedBox(height: 5),

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
                'Daftar Siswa',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kelola data & rekam akademik',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Import
        Material(
          color: AppColors.primaryLight,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              // TODO: Import siswa
            },
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.upload_file_outlined,
                color: AppColors.primary,
                size: 21,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Tambah siswa
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Tambah siswa
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Siswa',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(96, 44),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari nama atau NISN siswa...',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 21,
          color: AppColors.textSecondary,
        ),
        suffixIcon: const Icon(
          Icons.tune,
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
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return Container(
      width: double.infinity,
      height: 145,
      padding: const EdgeInsets.all(16),
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
              const Text(
                'Total Siswa',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const Spacer(),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
            ],
          ),

          const Spacer(),

          const Text(
            '864',
            style: TextStyle(
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, size: 13, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  '+18 semester ini',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIST HEADER
  // ============================================================

  Widget _buildListHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Daftar Profil Siswa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          'Menampilkan ${count > 5 ? 5 : count} dari 864',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(_StudentData student) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentAvatar(student),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 7),

                          _buildStatus(student.status),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'NISN: ${student.nisn} • Kelas ${student.className}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          student.classLabel,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 17,
                  color: AppColors.textSecondary,
                ),

                const SizedBox(width: 6),

                const Text(
                  'Siswa Terdaftar',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(),

                // _buildActionButton(
                //   icon: Icons.edit_outlined,
                //   background: AppColors.primaryLight,
                //   foreground: AppColors.primary,
                //   onTap: () {
                //     // TODO: Edit siswa
                //   },
                // ),

                // const SizedBox(width: 7),

                // _buildActionButton(
                //   icon: Icons.delete_outline,
                //   background: const Color(0xFFFFD9D5),
                //   foreground: AppColors.error,
                //   onTap: () {
                //     // TODO: Hapus siswa
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAvatar(_StudentData student) {
    if (student.image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(
          student.image!,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildInitialAvatar(student);
          },
        ),
      );
    }

    return _buildInitialAvatar(student);
  }

  Widget _buildInitialAvatar(_StudentData student) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: Text(
        student.initials,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF63E6B2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF00875A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Aktif',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006B4A),
            ),
          ),
        ],
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
          height: 40,
          child: Icon(icon, size: 18, color: foreground),
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
            Icon(Icons.keyboard_arrow_down, size: 20),
            SizedBox(width: 6),
            Text(
              'Muat Lebih Banyak Siswa',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  List<_StudentData> _getFilteredStudents() {
    if (_selectedFilter == 0) {
      return _students;
    }

    final filter = _filters[_selectedFilter];

    if (filter == 'Alumni') {
      return [];
    }

    final classNumber = filter.replaceAll('Kelas ', '');

    return _students.where((student) {
      return student.className.startsWith(classNumber);
    }).toList();
  }
}

class _StudentData {
  final String name;
  final String nisn;
  final String className;
  final String classLabel;
  final String initials;
  final String status;
  final String? image;

  const _StudentData({
    required this.name,
    required this.nisn,
    required this.className,
    required this.classLabel,
    required this.initials,
    required this.status,
    this.image,
  });
}
