import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/dashboard_service.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/student_style_filter_bar.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  static const List<String> _jenjangFilters = [
    'Semua Jenjang',
    'SD',
    'SMP',
    'SMA',
    'Umum',
  ];
  static const List<String> _statusFilters = [
    'Semua Status',
    'Aktif',
    'Nonaktif',
  ];

  String _selectedJenjang = 'Semua Jenjang';
  String _selectedStatus = 'Semua Status';

  bool _isLoading = true;
  List<Map<String, dynamic>> _students = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedJenjang != 'Semua Jenjang' ||
      _selectedStatus != 'Semua Status';

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedJenjang = 'Semua Jenjang';
      _selectedStatus = 'Semua Status';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      final list = await DashboardService.fetchStudents();
      if (mounted) {
        setState(() {
          _students = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'S';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    final q = _searchQuery.toLowerCase();

    return _students.where((s) {
      final name = (s['nama'] ?? '').toString().toLowerCase();
      final nisn = (s['nisn'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      final kelas = (s['kelas'] ?? '').toString().toLowerCase();

      final matchQuery =
          q.isEmpty ||
          name.contains(q) ||
          nisn.contains(q) ||
          email.contains(q) ||
          kelas.contains(q);

      final matchJenjang = matchesJenjangFilter(
        s['jenjang']?.toString(),
        _selectedJenjang,
      );

      final rawStatus = (s['status'] ?? 'Aktif').toString().trim();
      final statusLower = rawStatus.isEmpty ? 'aktif' : rawStatus.toLowerCase();
      final matchStatus =
          _selectedStatus == 'Semua Status' ||
          statusLower == _selectedStatus.toLowerCase();

      return matchQuery && matchJenjang && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredStudents();

    return SafeArea(
      child: Column(
        children: [
          AppHeader(title: 'Manajemen Siswa', onNotificationTap: () {}),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadStudents,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                    _buildListHeader(filtered.length),

                    const SizedBox(height: 10),

                    if (_isLoading && _students.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_outlined, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              _hasActiveFilters
                                  ? 'Tidak ada siswa yang cocok dengan filter atau kata kunci saat ini.'
                                  : 'Belum ada data siswa di database',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                            if (_hasActiveFilters) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                                label: const Text('Reset Filter'),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      ...filtered.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildStudentCard(student),
                        ),
                      ),
                  ],
                ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar Siswa',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Kelola data & siswa terdaftar (${_students.length} Siswa)',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return StudentStyleSearchField(
      controller: _searchController,
      hintText: 'Cari nama, NISN, kelas, atau email siswa...',
      hasQuery: _searchQuery.isNotEmpty,
      onChanged: (val) => setState(() => _searchQuery = val.trim()),
      onSubmitted: (val) => setState(() => _searchQuery = val.trim()),
      onClear: () {
        _searchController.clear();
        setState(() => _searchQuery = '');
      },
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudentStyleFilterChipBar(
          options: _jenjangFilters,
          selectedOption: _selectedJenjang,
          onSelected: (val) => setState(() => _selectedJenjang = val),
        ),
        const SizedBox(height: 8),
        StudentStyleFilterChipBar(
          options: _statusFilters,
          selectedOption: _selectedStatus,
          onSelected: (val) => setState(() => _selectedStatus = val),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              Text(
                'Total Siswa Terdaftar',
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '${_students.length}',
            style: GoogleFonts.nunitoSans(
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDDF3FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(
                  'Data terhubung dari database',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
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
        Expanded(
          child: Text(
            'Daftar Profil Siswa',
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_hasActiveFilters) ...[
          TextButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text(
              'Reset',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(
              foregroundColor: kStudentFilterBlue,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          'Menampilkan $count siswa',
          style: GoogleFonts.nunitoSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final name = student['nama']?.toString() ?? 'Siswa';
    final nisn = student['nisn']?.toString() ?? '-';
    final jenjang = student['jenjang']?.toString() ?? 'Umum';
    final status = student['status']?.toString() ?? 'Aktif';
    final totalPoin = student['total_poin'] ?? 0;
    final initials = _getInitials(name);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentAvatar(initials),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 7),

                          _buildStatus(status),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'NISN: $nisn • Jenjang $jenjang',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDF3FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
                            ),
                            child: Text(
                              jenjang,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                            ),
                            child: Text(
                              '⭐ $totalPoin XP',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFE2F0FD), width: 1.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),

                const SizedBox(width: 6),

                Text(
                  'Siswa Pembelajar Terdaftar',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAvatar(String initials) {
    return Container(
      width: 48,
      height: 48,
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
          initials,
          style: GoogleFonts.nunitoSans(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    final bool active = status.toLowerCase() == 'aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD1FAE5) : const Color(0xFFEFF1F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? const Color(0xFFA7F3D0) : const Color(0xFFDCEFFF),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF059669) : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? const Color(0xFF059669) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
