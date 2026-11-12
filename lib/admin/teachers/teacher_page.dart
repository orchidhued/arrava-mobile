import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/dashboard_service.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/student_style_filter_bar.dart';
import 'teacher_detail_page.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  static const List<String> _filters = [
    'Semua',
    'Aktif',
    'Nonaktif',
    'Tanpa Akun',
    'Ada Email',
    'Ada Telepon',
  ];

  bool _isLoading = true;
  List<Map<String, dynamic>> _teachers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedFilter != 'Semua';

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedFilter = 'Semua';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      final list = await DashboardService.fetchTeachers();
      if (mounted) {
        setState(() {
          _teachers = list;
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
    if (name.isEmpty) return 'G';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  List<Map<String, dynamic>> _getFilteredTeachers() {
    final q = _searchQuery.toLowerCase();

    return _teachers.where((t) {
      final name = (t['nama'] ?? '').toString().toLowerCase();
      final nik = (t['nik'] ?? '').toString().toLowerCase();
      final phone = (t['no_telepon'] ?? '').toString().trim();
      final email = (t['email'] ?? '').toString().trim();
      final rawStatus = (t['status'] ?? 'Aktif').toString().trim();
      final statusLower = rawStatus.isEmpty ? 'aktif' : rawStatus.toLowerCase();

      final matchQuery =
          q.isEmpty ||
          name.contains(q) ||
          nik.contains(q) ||
          phone.toLowerCase().contains(q) ||
          email.toLowerCase().contains(q);

      final bool matchFilter;
      switch (_selectedFilter) {
        case 'Aktif':
          matchFilter = statusLower == 'aktif';
          break;
        case 'Nonaktif':
          matchFilter = statusLower == 'nonaktif';
          break;
        case 'Tanpa Akun':
          matchFilter = statusLower == 'tanpa akun';
          break;
        case 'Ada Email':
          matchFilter = email.isNotEmpty && email != '-';
          break;
        case 'Ada Telepon':
          matchFilter = phone.isNotEmpty && phone != '-';
          break;
        default:
          matchFilter = true;
      }

      return matchQuery && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredTeachers();

    return SafeArea(
      child: Column(
        children: [
          AppHeader(title: 'Manajemen Guru', onNotificationTap: () {}),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadTeachers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                    StudentStyleFilterChipBar(
                      options: _filters,
                      selectedOption: _selectedFilter,
                      onSelected: (val) => setState(() => _selectedFilter = val),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Text(
                          'Menampilkan ${filtered.length} guru',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kStudentFilterMuted,
                          ),
                        ),
                        const Spacer(),
                        if (_hasActiveFilters)
                          TextButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh_rounded, size: 15),
                            label: const Text(
                              'Reset Filter',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: kStudentFilterBlue,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (_isLoading && _teachers.isEmpty)
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
                                  ? 'Tidak ada guru yang cocok dengan filter atau kata kunci saat ini.'
                                  : 'Belum ada data guru di database',
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
                        (teacher) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildTeacherCard(teacher),
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
                'Daftar Guru',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Kelola tenaga pendidik (${_teachers.length} Guru Terdaftar)',
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
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    final total = _teachers.length;
    final withNik = _teachers.where((t) => (t['nik'] ?? '').toString().isNotEmpty).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.groups_outlined,
            iconBackground: AppColors.primaryLight,
            iconColor: AppColors.primary,
            value: '$total',
            label: 'Total Guru',
            badge: 'Database',
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
            value: '$withNik',
            label: 'Dengan NIK/NIP',
            badge: 'Terverifikasi',
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
      height: 126,
      padding: const EdgeInsets.all(14),
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB2E7FC), width: 1),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 26,
              height: 1,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
    return StudentStyleSearchField(
      controller: _searchController,
      hintText: 'Cari nama, email, NIK, atau telepon guru...',
      hasQuery: _searchQuery.isNotEmpty,
      onChanged: (val) => setState(() => _searchQuery = val.trim()),
      onClear: () {
        _searchController.clear();
        setState(() => _searchQuery = '');
      },
    );
  }

  // ============================================================
  // TEACHER CARD
  // ============================================================

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final name = teacher['nama']?.toString() ?? 'Guru';
    final nik = teacher['nik']?.toString() ?? '-';
    final phone = teacher['no_telepon']?.toString() ?? '-';
    final email = teacher['email']?.toString().trim() ?? '';
    final rawStatus = teacher['status']?.toString().trim() ?? '';
    final status = rawStatus.isNotEmpty ? rawStatus : 'Aktif';
    final initials = _getInitials(name);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherDetailPage(
              name: name,
              nip: nik,
              subject: email.isNotEmpty
                  ? email
                  : (phone != '-' ? 'Telp: $phone' : 'Guru Pendidik'),
              role: 'Tenaga Pendidik',
              status: status,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(initials),

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
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          _buildStatus(status),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'NIK / NIP: $nik',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: [
                _buildTag('Tenaga Pengajar', primary: true),
                if (phone != '-' && phone.trim().isNotEmpty)
                  _buildTag('📞 $phone', primary: false),
                if (email.isNotEmpty) _buildTag('✉️ $email', primary: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String initials) {
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
    final normalized = status.trim().toLowerCase();
    final Color bg;
    final Color border;
    final Color fg;
    if (normalized == 'nonaktif') {
      bg = const Color(0xFFFFE4E6);
      border = const Color(0xFFFECDD3);
      fg = const Color(0xFFE11D48);
    } else if (normalized == 'tanpa akun') {
      bg = const Color(0xFFFEF3C7);
      border = const Color(0xFFFDE68A);
      fg = const Color(0xFFD97706);
    } else {
      bg = const Color(0xFFD1FAE5);
      border = const Color(0xFFA7F3D0);
      fg = const Color(0xFF059669);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {required bool primary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary ? const Color(0xFFDDF3FF) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary ? const Color(0xFFB2E7FC) : const Color(0xFFDCEFFF),
          width: 1,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.nunitoSans(
          fontSize: 10.5,
          color: primary ? AppColors.primaryDark : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
