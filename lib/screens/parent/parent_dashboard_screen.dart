import 'package:flutter/material.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/utils/logout_dialog.dart';
import '../modules/student_module_list_page.dart';
import '../quizzes/student_quiz_list_page.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _currentIndex = 0;
  String _parentName = 'Orang Tua / Wali';
  String _parentEmail = '';
  final String _parentStatus = 'Aktif';

  static const Color _primary = Color(0xFF2563EB);
  static const Color _indigo = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    try {
      final name = await SecureStorage.read('user_name');
      final email = await SecureStorage.read('user_email');
      if (mounted) {
        setState(() {
          if (name != null && name.trim().isNotEmpty) {
            _parentName = name.trim();
          }
          if (email != null && email.trim().isNotEmpty) {
            _parentEmail = email.trim();
          }
        });
      }
    } catch (_) {
      // Abaikan jika penyimpanan lokal kosong
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _buildCurrentTab(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const Scaffold(
          backgroundColor: Color(0xFFF8FAFC),
          body: StudentModuleListPage(),
        );
      case 2:
        return const Scaffold(
          backgroundColor: Color(0xFFF8FAFC),
          body: StudentQuizListPage(),
        );
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadParentData,
        color: _primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER: Profil & Logout
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: const Icon(
                      Icons.family_restroom_rounded,
                      color: _indigo,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _parentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, size: 13, color: _indigo),
                        SizedBox(width: 4),
                        Text(
                          'Orang Tua',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                    tooltip: 'Keluar',
                    onPressed: () => showLogoutConfirmationDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. HERO BANNER PORTAL ORANG TUA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🛡️ PORTAL PENDAMPINGAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '● Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pantau Prestasi & Keaktifan Belajar Ananda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dampingi proses belajar putra-putri Anda melalui pengawasan modul materi, pengerjaan kuis, dan pencapaian lencana secara transparan.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 3. STATS & FITUR MONITORING GRID
              const Text(
                'Layanan Monitoring Belajar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  final double w = constraints.maxWidth;
                  final int cols = w >= 600 ? 4 : 2;

                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: cols == 2 ? 1.35 : 1.2,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                        title: 'Materi Modul',
                        subtitle: 'Akses modul & bahan ajar ananda',
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      _buildFeatureCard(
                        icon: Icons.quiz_rounded,
                        color: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFF5F3FF),
                        title: 'Kuis & Nilai',
                        subtitle: 'Daftar latihan & evaluasi kuis',
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                      _buildFeatureCard(
                        icon: Icons.emoji_events_rounded,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        title: 'Pencapaian',
                        subtitle: 'Lencana prestasi & poin XP',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pencapaian ananda tersinkronisasi otomatis dari pengerjaan kuis.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.qr_code_scanner_rounded,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                        title: 'Presensi QR',
                        subtitle: 'Kehadiran harian tercatat',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Presensi dilakukan oleh ananda di sekolah menggunakan scan QR.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              // 4. TIPS PENDAMPINGAN ORANG TUA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tips Pendampingan Belajar di Rumah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTipItem('1. Luangkan 15-20 menit sehari untuk mereview materi dan kuis bersama anak.'),
                    _buildTipItem('2. Berikan apresiasi saat anak berhasil menyelesaikan latihan soal dan meraih lencana baru.'),
                    _buildTipItem('3. Jika ada materi yang belum tuntas, bantu ananda mengulang video pembelajaran pada tab Materi.'),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 5. TOMBOL AKSES CEPAT
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _currentIndex = 1),
                      icon: const Icon(Icons.menu_book_rounded, size: 16),
                      label: const Text('Buka Materi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _currentIndex = 2),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Lihat Kuis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF475569),
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: const Icon(Icons.family_restroom_rounded, size: 40, color: _indigo),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _parentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _parentEmail.isNotEmpty ? _parentEmail : 'Akun Orang Tua Terverifikasi',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 5),
                        Text(
                          'Status Akun: $_parentStatus',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Opsi & Pengaturan
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: _primary),
                    title: const Text('Peran Akun', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    trailing: const Text('Orang Tua / Wali Siswa', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                  ),
                  const Divider(height: 1),
                  FutureBuilder<bool>(
                    future: PreferencesService.isSoundEnabled(),
                    builder: (context, snap) {
                      final val = snap.data ?? true;
                      return SwitchListTile(
                        secondary: const Icon(Icons.volume_up_rounded, color: Color(0xFF7C3AED)),
                        title: const Text('Efek Suara Kuis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: const Text('Bunyi audio pada pratinjau kuis', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        value: val,
                        onChanged: (newVal) async {
                          await PreferencesService.setSoundEnabled(newVal);
                          setState(() {});
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
                    title: const Text('Versi Aplikasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    trailing: const Text('1.0.0 (Portal Orang Tua)', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => showLogoutConfirmationDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: 'Kuis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
