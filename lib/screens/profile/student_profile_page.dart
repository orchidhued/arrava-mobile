import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/api_constants.dart';
import '../../services/dashboard_service.dart';
import '../../shared/utils/logout_dialog.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await DashboardService.fetchStudentProfile();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showEditProfileSheet(Map<String, dynamic> user) {
    final usernameController = TextEditingController(text: user['username']?.toString() ?? '');
    final hpController = TextEditingController(text: user['nomor_hp']?.toString() == '-' ? '' : user['nomor_hp']?.toString() ?? '');
    final sekolahController = TextEditingController(text: user['asal_sekolah']?.toString() == '-' ? '' : user['asal_sekolah']?.toString() ?? '');
    final passwordController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Edit Data Profil Siswa',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Perbarui informasi data pribadi akun pembelajaran Anda.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Username
                const Text('Username', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan username',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Asal Sekolah
                const Text('Asal Sekolah', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: sekolahController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: SMAN 1 Jakarta',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Nomor HP
                const Text('Nomor Handphone / WhatsApp', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: hpController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 081234567890',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Password Baru (Opsional)
                const Text('Ubah Password (Kosongkan jika tidak ingin mengubah)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password baru minimal 6 karakter',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setSheetState(() => isSaving = true);
                            try {
                              final updatePayload = <String, dynamic>{
                                'username': usernameController.text.trim(),
                                'asal_sekolah': sekolahController.text.trim(),
                                'nomor_hp': hpController.text.trim(),
                              };
                              if (passwordController.text.trim().isNotEmpty) {
                                updatePayload['password'] = passwordController.text.trim();
                              }

                              await DashboardService.updateStudentProfile(updatePayload);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              _loadProfile();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF059669),
                                    content: Text('Profil berhasil diperbarui! 🎉'),
                                  ),
                                );
                              }
                            } catch (e) {
                              setSheetState(() => isSaving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFFE11D48),
                                    content: Text('Gagal menyimpan: $e'),
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _profileData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(title: const Text('Profil Siswa'), backgroundColor: Colors.white),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              const Text('Gagal Memuat Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(_error ?? 'Terjadi kesalahan.', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _profileData!['user'] as Map<String, dynamic>? ?? {};
    final rank = _profileData!['rank'] as Map<String, dynamic>? ?? {};
    final stats = _profileData!['stats'] as Map<String, dynamic>? ?? {};
    final achievements = (_profileData!['achievements'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final riwayatKuis = (_profileData!['riwayat_kuis'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final String nama = user['nama']?.toString() ?? 'Siswa';
    final String username = user['username']?.toString() ?? nama;
    final String email = user['email']?.toString() ?? '-';
    final String jenjang = user['nama_jenjang']?.toString() ?? '-';
    final String nisn = user['nisn']?.toString() ?? '-';
    final String sekolah = user['asal_sekolah']?.toString() ?? '-';
    final String nomorHp = user['nomor_hp']?.toString() ?? '-';
    final String? qrPayload = user['qr_payload']?.toString();
    final String? resolvedAvatar = ApiConstants.resolveMediaUrl(user['foto_profil']?.toString());

    final String currentRank = rank['current_rank']?.toString() ?? 'Pemula';
    final int currentPoints = (rank['current_points'] is int) ? rank['current_points'] : int.tryParse(rank['current_points']?.toString() ?? '0') ?? 0;
    final int nextPoints = (rank['next_points'] is int) ? rank['next_points'] : int.tryParse(rank['next_points']?.toString() ?? '100') ?? 100;
    final int pointsNeeded = (rank['points_needed'] is int) ? rank['points_needed'] : int.tryParse(rank['points_needed']?.toString() ?? '0') ?? 0;
    final int percent = (rank['percent'] is int) ? rank['percent'] : int.tryParse(rank['percent']?.toString() ?? '0') ?? 0;
    final bool isMaxRank = rank['is_max'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 24, color: Color(0xFF2563EB)),
            tooltip: 'Edit Profil',
            onPressed: () => _showEditProfileSheet(user),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFEF4444)),
            tooltip: 'Keluar',
            onPressed: () => showLogoutConfirmationDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Card (Avatar + Info + Edit Button)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: resolvedAvatar != null && resolvedAvatar.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                resolvedAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text('@$username • $jenjang', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Siswa Terdaftar 🧑‍🎓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                                child: Text('Rank: $currentRank ★', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Rank & EXP Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TINGKAT KEMAMPUAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
                            SizedBox(height: 2),
                            Text('Peringkat & EXP Belajar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt, color: Colors.amber, size: 16),
                              const SizedBox(width: 3),
                              Text('$currentPoints EXP', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.amber, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rank Card Inner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('🏆', style: TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Peringkat Saat Ini', style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
                                Text(currentRank, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                              ],
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (percent / 100.0).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isMaxRank
                          ? 'Peringkat Tertinggi (MAX TIER) 👑'
                          : 'Kurang $pointsNeeded EXP lagi menuju rank berikutnya ($currentPoints / $nextPoints EXP)',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Statistik Belajar Grid 4 Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Percobaan Kuis',
                      value: '${stats['total_percobaan'] ?? 0}',
                      icon: Icons.history_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Kuis Lulus',
                      value: '${stats['kuis_lulus'] ?? 0}',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Kuis Dikerjakan',
                      value: '${stats['jumlah_kuis'] ?? 0}',
                      icon: Icons.quiz_outlined,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Total Poin Kuis',
                      value: '${stats['total_poin_didapat'] ?? 0} Pts',
                      icon: Icons.stars_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Kartu Pelajar & QR Presensi Digital
              const Text(
                'Kartu Presensi Siswa',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BIMBEL ARRAVA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
                            Text('KARTU PRESENSI DIGITAL', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text(jenjang, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // QR Code Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                        ],
                      ),
                      child: QrImageView(
                        data: qrPayload ?? nisn,
                        version: QrVersions.auto,
                        size: 150.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('NISN: $nisn', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text('Tunjukkan ke guru saat absensi kelas', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Data Pribadi & Sekolah Detail
              const Text(
                'Data Pribadi & Sekolah',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Nama Lengkap', nama, Icons.person_outline),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoRow('Email', email, Icons.email_outlined),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoRow('NISN', nisn, Icons.badge_outlined),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoRow('Jenjang Akademik', jenjang, Icons.school_outlined),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoRow('Asal Sekolah', sekolah, Icons.account_balance_outlined),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoRow('Nomor Handphone', nomorHp, Icons.phone_android_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 6. Tanda Penghargaan / Achievements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lencana Penghargaan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: Text('${achievements.length} Lencana', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (achievements.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Center(
                    child: Column(
                      children: [
                        Text('🎖️', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 6),
                        Text('Belum ada penghargaan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
                        SizedBox(height: 2),
                        Text('Selesaikan kuis untuk meraih lencana penghargaan pertamamu!', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final ach = achievements[index];
                    final String? resolvedBadge = ApiConstants.resolveMediaUrl(ach['gambar_url']?.toString());
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                            child: resolvedBadge != null && resolvedBadge.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      resolvedBadge,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Text('⭐', style: TextStyle(fontSize: 18))),
                                    ),
                                  )
                                : const Center(child: Text('⭐', style: TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(ach['nama']?.toString() ?? 'Lencana', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                Text(ach['tanggal']?.toString() ?? '', style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // 7. Riwayat Kuis Terakhir
              const Text('Riwayat Kuis Terakhir', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              if (riwayatKuis.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Center(
                    child: Text('Belum ada riwayat pengerjaan kuis.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: riwayatKuis.length,
                  itemBuilder: (context, index) {
                    final item = riwayatKuis[index];
                    final bool isLulus = item['is_lulus'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isLulus ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isLulus ? Icons.check_circle_rounded : Icons.schedule_rounded,
                              size: 18,
                              color: isLulus ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['judul_quiz']?.toString() ?? 'Kuis', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(item['tanggal']?.toString() ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${item['poin_didapat']} Poin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isLulus ? const Color(0xFF059669) : const Color(0xFFD97706))),
                              Text(isLulus ? 'Lulus' : 'Belum Lulus', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLulus ? const Color(0xFF059669) : const Color(0xFFD97706))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // 8. Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => showLogoutConfirmationDialog(context),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
