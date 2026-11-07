import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/attendance_service.dart';
import 'attendance_scanner_page.dart';

enum _AttendanceFilter { all, present, absent }

class AttendanceRecapPage extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;
  final String className;
  final String jenjang;

  const AttendanceRecapPage({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
    required this.className,
    required this.jenjang,
  });

  @override
  State<AttendanceRecapPage> createState() => _AttendanceRecapPageState();
}

class _AttendanceRecapPageState extends State<AttendanceRecapPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _recap = {};
  _AttendanceFilter _filter = _AttendanceFilter.all;

  @override
  void initState() {
    super.initState();
    _loadRecap();
  }

  Future<void> _loadRecap() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recap = await AttendanceService.fetchSessionRecap(widget.sessionId);
      if (mounted) {
        setState(() {
          _recap = recap;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openScanner() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AttendanceScannerPage(
          sessionId: widget.sessionId,
          sessionTitle: widget.sessionTitle,
          className: widget.className,
        ),
      ),
    );
    if (mounted) await _loadRecap();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _recap['ringkasan'] is Map
        ? Map<String, dynamic>.from(_recap['ringkasan'] as Map)
        : <String, dynamic>{};
    final students = _recap['siswa'] is List
        ? List<Map<String, dynamic>>.from(_recap['siswa'] as List)
        : <Map<String, dynamic>>[];
    final filteredStudents = students.where(_matchesFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.jenjang),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadRecap,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Text(
              widget.sessionTitle,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.jenjang} • ${widget.className}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            if (_isLoading && _recap.isEmpty)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_error != null)
              _buildError()
            else ...[
              _buildSummary(summary),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar Siswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${filteredStudents.length} siswa',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFilters(summary),
              const SizedBox(height: 10),
              if (filteredStudents.isEmpty)
                _buildNoStudents()
              else
                ...filteredStudents.map(_buildStudentRow),
            ],
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(Map<String, dynamic> student) {
    final status = student['status']?.toString();
    return switch (_filter) {
      _AttendanceFilter.all => true,
      _AttendanceFilter.present => status == 'hadir' || status == 'terlambat',
      _AttendanceFilter.absent => status == 'tidak_hadir',
    };
  }

  Widget _buildSummary(Map<String, dynamic> summary) {
    final present = _asInt(summary['hadir']) + _asInt(summary['terlambat']);
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: 'Hadir',
            count: present,
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: 'Tidak hadir',
            count: _asInt(summary['tidak_hadir']),
            icon: Icons.highlight_off_outlined,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: 'Total',
            count: _asInt(summary['total']),
            icon: Icons.groups_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 9),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(Map<String, dynamic> summary) {
    final options = [
      (_AttendanceFilter.all, 'Semua', _asInt(summary['total'])),
      (
        _AttendanceFilter.present,
        'Hadir',
        _asInt(summary['hadir']) + _asInt(summary['terlambat']),
      ),
      (_AttendanceFilter.absent, 'Tidak hadir', _asInt(summary['tidak_hadir'])),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final selected = _filter == option.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${option.$2} (${option.$3})'),
              selected: selected,
              onSelected: (_) => setState(() => _filter = option.$1),
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> student) {
    final status = student['status']?.toString() ?? 'tidak_hadir';
    final present = status == 'hadir' || status == 'terlambat';
    final late = status == 'terlambat';
    final name = student['nama']?.toString() ?? 'Siswa';
    final nisn = student['nisn']?.toString();
    final time = student['waktu_scan']?.toString();
    final color = present ? AppColors.success : AppColors.error;
    final statusText = late
        ? 'Terlambat${time == null ? '' : ' • $time'}'
        : present
        ? 'Hadir${time == null ? '' : ' • $time'}'
        : 'Tidak hadir';

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              _initials(name),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (nisn != null && nisn.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'NISN: $nisn',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStudents() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Tidak ada siswa pada kategori ini.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadRecap,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isEmpty ? 'S' : name[0].toUpperCase();
  }
}
