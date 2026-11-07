import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/attendance_service.dart';
import '../../shared/widgets/app_header.dart';
import 'attendance_recap_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await AttendanceService.fetchActiveSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppHeader(title: 'Presensi', onNotificationTap: () {}),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadSessions,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  const Text(
                    'Presensi Siswa',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih jenjang dan sesi untuk melihat rekap presensi siswa.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Presensi per Jenjang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_sessions.length} sesi',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading && _sessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(36),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (_error != null)
                    _buildErrorState()
                  else if (_sessions.isEmpty)
                    _buildEmptyState()
                  else
                    ..._buildSessionsByJenjang(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSessionsByJenjang() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final session in _sessions) {
      final kelas = session['kelas'] is Map
          ? Map<String, dynamic>.from(session['kelas'] as Map)
          : <String, dynamic>{};
      final jenjang = kelas['jenjang']?.toString().trim();
      grouped
          .putIfAbsent(
            jenjang == null || jenjang.isEmpty ? 'Jenjang lainnya' : jenjang,
            () => [],
          )
          .add(session);
    }

    return grouped.entries.expand((entry) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Text(
            entry.key,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        ...entry.value.map(_buildSessionCard),
      ];
    }).toList();
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final kelas = session['kelas'] is Map
        ? Map<String, dynamic>.from(session['kelas'] as Map)
        : <String, dynamic>{};
    final sessionId = int.tryParse(session['id_sesi']?.toString() ?? '');
    final className = kelas['nama']?.toString() ?? 'Kelas';
    final title = session['judul']?.toString() ?? 'Sesi presensi';
    final meeting = session['pertemuan_ke']?.toString();
    final jenjang = kelas['jenjang']?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: sessionId == null
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AttendanceRecapPage(
                        sessionId: sessionId,
                        sessionTitle: title,
                        className: className,
                        jenjang: jenjang ?? 'Jenjang lainnya',
                      ),
                    ),
                  );
                  if (mounted) await _loadSessions();
                },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.class_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$title${meeting == null ? '' : ' • Pertemuan $meeting'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Lihat siswa hadir dan tidak hadir',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 23,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 42,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada sesi aktif',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Sesi untuk kelas yang aktif hari ini akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _loadSessions,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
