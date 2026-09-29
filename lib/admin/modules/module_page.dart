import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import 'module_detail_page.dart';
import 'add_module_page.dart';

class ModulePage extends StatefulWidget {
  const ModulePage({super.key});

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  int _selectedFilter = 0;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Semua',
    'Fisika & Biologi',
    'Bahasa Inggris',
    'Sejarah & IPS',
    'Matematika',
  ];

  final List<_ModuleData> _modules = [
    _ModuleData(
      category: 'Fisika & Biologi',
      title: 'IPA Terpadu SMA',
      description: 'Materi Biologi dasar, Fisika dasar, dan Kimia dasar semester ganjil.',
      className: 'Kelas 10',
      students: '128 Siswa',
      teacher: 'Dr. Emily Okonkwo',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBrxe8EZ9RJAD9uX3JzLYzf50ofAGYTtk4pXQoo3IZTOq_cF-QQmpCDOkewHwLcNz192xlPO0sI_dXOWMq1vj6bH2DnLVy_ewDubaYF_1wDPDjpfFWmDXT7iuz8iNAm245MFy5bkVB2hdGHHP8P1uWAfqIGOmSvB2jRcs846fGthImSuyuVaFoOMn6W91igmqQTn9T4SUjnUiui6PiRMxr6LnShVeZYlyfytJYk8A20YVuEfsXlPzBGFw',
    ),

    _ModuleData(
      category: 'Bahasa Inggris',
      title: 'Bahasa Inggris Conversation',
      description:
          'Panduan praktis percakapan bahasa Inggris tingkat menengah.',
      className: 'Kelas 11',
      students: '94 Siswa',
      teacher: 'Maya Chen, M.Pd.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC-K0XaoChg_orBi6YKIT3b41pb7UxWoI0nHGTfnFBN3zQmxKp9o4AMkieD_zM8UUTJxgfOLsz17X79q7suBjR4zVL0y3RCTA1ltWkDQJu_Nq9nZPNYAVQAtdoDS8p5ZDn-aCtW9xa0RsdNQtQ8e2jisJf_DB-3vh7nelH5OSPBZfzlTFQTsxJ7Mg_Me6p0e-7zvcGco2K0lRPTYFcMMOjS-UrhxTTWnp4hn8qrLu_R7yw5XbbMC7IO_w',
    ),

    _ModuleData(
      category: 'Sejarah & IPS',
      title: 'Sejarah Peradaban Dunia',
      description:
          'Melacak sejarah peradaban besar dunia dari masa prasejarah.',
      className: 'Kelas 12',
      students: '112 Siswa',
      teacher: 'James Holloway',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMY5W9DC9BGOuO2RDCHs5LHKnOY86enoD1VrCanWTXtfnQROoRZviNHgiu86-n6pU1ZUNLNIRGC6scxscP1sodkJE-OhTiTYLu0rAJjRZG-In0a4cqA3Fffp0D1i7My2h2vdqRfOTZN4UclSGE2P7e6SBuIUp63Nr3N2d5t8fqS9fFhjGrG03J66-GDqht3S7FZOr5Q7p-f2nkE3H1JO50UPOBevB8FxlDZLYqHhLktF-aEEj5tZFVLA',
    ),

    _ModuleData(
      category: 'Matematika',
      title: 'Matematika Kalkulus Dasar',
      description:
          'Konsep dasar kalkulus, fungsi, limit, turunan, dan penerapannya.',
      className: 'Kelas 12',
      students: '106 Siswa',
      teacher: 'Michael Anderson',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCCj0wjba2FvFZs45L1b-PVXBuHYNhTogYaKt0qO-4ILyKf77PADZ_RhIQFqduOYsNnLeJD61qu1cI-p6FWfZzI0sD1anv5UlAdsFLbiQa4bqp90Yms09zl9wAT5PeONeAL8Y4y-_zOzlfAEyWACYdJYSNxsqgQQlPQBX0f3OPIYF853kPq4PuQsl1lYbBvdXG1pt8v2gxDlCELHDwpzHEs4AUb6oa9fHlDwLbyYL1maIA9KsXQuqz9nA',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modules = _getFilteredModules();

    return SafeArea(
      child: Column(
        children: [
          AppHeader(title: 'Kelola Modul', onNotificationTap: () {}),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(),

                  const SizedBox(height: 18),

                  _buildSearchField(),

                  const SizedBox(height: 12),

                  _buildFilters(),

                  const SizedBox(height: 18),

                  _buildStatistics(),

                  const SizedBox(height: 18),

                  ...modules.map(
                    (module) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildModuleCard(module),
                    ),
                  ),

                  if (modules.isEmpty) _buildEmptyState(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manajemen Modul',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Buat, distribusikan, dan kelola modul pelajaran digital kelas.',
          style: TextStyle(
            fontSize: 11,
            height: 1.45,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddModulePage()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Tambah Modul',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari data, laporan, kelas...',
        hintStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  // FILTER

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
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
  // STATISTIC
  // ============================================================

  Widget _buildStatistics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.layers_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Modul Terdaftar',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '128 Modul',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDDF8EC),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'Kelas Aktif',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00875A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MODULE CARD
  // ============================================================

  Widget _buildModuleCard(_ModuleData module) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModuleDetailPage(
              moduleName: module.title,
              category: module.category,
              description: module.description,
              teacher: module.teacher,
              status: 'Aktif',
              date: '24 Sep 2026',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImage(module),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTag(module.category),

                  const SizedBox(height: 7),

                  Text(
                    module.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    module.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        module.className,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        module.students,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Text(
                  //         'Oleh: ${module.teacher}',
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //         style: const TextStyle(
                  //           fontSize: 9,
                  //           color: AppColors.textSecondary,
                  //         ),
                  //       ),
                  //     ),

                  //     _buildActionButton(
                  //       icon: Icons.edit_outlined,
                  //       color: AppColors.primary,
                  //       onTap: () {},
                  //     ),

                  //     const SizedBox(width: 4),

                  //     _buildActionButton(
                  //       icon: Icons.delete_outline,
                  //       color: AppColors.error,
                  //       onTap: () {},
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COVER IMAGE
  // ============================================================

  Widget _buildCoverImage(_ModuleData module) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Image.network(
        module.imageUrl,
        width: 72,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 72,
            height: 96,
            color: const Color(0xFFE8F0FF),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: 72,
            height: 96,
            color: const Color(0xFFE8F0FF),
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CATEGORY TAG
  // ============================================================

  Widget _buildCategoryTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 42,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'Modul tidak ditemukan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER DATA
  // ============================================================

  List<_ModuleData> _getFilteredModules() {
    return _modules.where((module) {
      final matchesFilter =
          _selectedFilter == 0 || module.category == _filters[_selectedFilter];

      final query = _searchQuery.trim();

      final matchesSearch =
          query.isEmpty ||
          module.title.toLowerCase().contains(query) ||
          module.category.toLowerCase().contains(query) ||
          module.teacher.toLowerCase().contains(query) ||
          module.className.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }
}

// ================================================================
// MODEL
// ================================================================

class _ModuleData {
  final String category;
  final String title;
  final String description;
  final String className;
  final String students;
  final String teacher;
  final String imageUrl;

  const _ModuleData({
    required this.category,
    required this.title,
    required this.description,
    required this.className,
    required this.students,
    required this.teacher,
    required this.imageUrl,
  });
}
