import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'student_qr_sheet.dart';

import '../../core/constants/api_constants.dart';
import '../../core/services/audio_service.dart';
import '../../core/storage/preferences_service.dart';
import '../../services/dashboard_service.dart';
import '../../shared/utils/logout_dialog.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  bool _isLoading = true;
  bool _isPickingPhoto = false;
  String? _error;
  Map<String, dynamic>? _profileData;
  bool _isSoundEnabled = true;
  bool _isHapticEnabled = true;

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
      final sound = await PreferencesService.isSoundEnabled();
      final haptic = await PreferencesService.isHapticEnabled();
      final data = await DashboardService.fetchStudentProfile();
      if (mounted) {
        setState(() {
          _isSoundEnabled = sound;
          _isHapticEnabled = haptic;
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

  Future<void> _changePhoto(Map<String, dynamic> user) async {
    if (_isPickingPhoto) return;
    setState(() => _isPickingPhoto = true);
    try {
      final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (photo == null || !mounted) return;
      if (await photo.length() > 2 * 1024 * 1024) {
        throw Exception(
          'Ukuran foto maksimal 2 MB. Pilih foto yang lebih kecil.',
        );
      }
      final bytes = await photo.readAsBytes();
      final extension = _photoExtension(bytes);
      if (extension == null) {
        throw Exception('Gunakan foto berformat JPG, PNG, atau WebP.');
      }
      if (!mounted) return;
      await _previewPhoto(user, bytes, 'foto-profil.$extension');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  String? _photoExtension(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'jpg';
    }
    const png = [137, 80, 78, 71, 13, 10, 26, 10];
    if (bytes.length >= 8 &&
        List.generate(8, (i) => bytes[i] == png[i]).every((match) => match)) {
      return 'png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'webp';
    }
    return null;
  }

  Future<void> _previewPhoto(
    Map<String, dynamic> user,
    Uint8List bytes,
    String filename,
  ) async {
    bool saving = false;
    bool saved = false;
    String? error;
    Map<String, dynamic>? updatedProfile;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (_, updateSheet) => PopScope(
          canPop: !saving,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _text('Ganti Foto Profil', size: 20),
                  const SizedBox(height: 6),
                  _text(
                    'JPG, PNG, atau WebP • Maksimal 2 MB',
                    size: 12,
                    color: _muted,
                  ),
                  const SizedBox(height: 22),
                  ClipOval(
                    child: Image.memory(
                      bytes,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, exception, stack) => const SizedBox(
                        width: 180,
                        height: 180,
                        child: Center(
                          child: Icon(Icons.broken_image_outlined, size: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFCD3845),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              updateSheet(() {
                                saving = true;
                                error = null;
                              });
                              try {
                                updatedProfile =
                                    await DashboardService.uploadStudentPhoto(
                                      bytes: bytes,
                                      filename: filename,
                                      previousPhoto: user['foto_profil']
                                          ?.toString(),
                                    );
                                saved = true;
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              } catch (e) {
                                if (sheetContext.mounted) {
                                  updateSheet(() {
                                    saving = false;
                                    error = e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    );
                                  });
                                }
                              }
                            },
                      style: FilledButton.styleFrom(backgroundColor: _blue),
                      icon: saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined, size: 19),
                      label: Text(saving ? 'Mengunggah...' : 'Simpan Foto'),
                    ),
                  ),
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(sheetContext),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (saved && mounted) {
      setState(() => _profileData = updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
      );
    }
  }

  void _showEditProfileSheet(Map<String, dynamic> user) {
    final usernameController = TextEditingController(
      text: user['username']?.toString() ?? '',
    );
    final hpController = TextEditingController(
      text: user['nomor_hp']?.toString() == '-'
          ? ''
          : user['nomor_hp']?.toString() ?? '',
    );
    final sekolahController = TextEditingController(
      text: user['asal_sekolah']?.toString() == '-'
          ? ''
          : user['asal_sekolah']?.toString() ?? '',
    );
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
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Perbarui informasi data pribadi akun pembelajaran Anda.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _isPickingPhoto
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          _changePhoto(user);
                        },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Pilih Foto Profil'),
                ),
                const SizedBox(height: 14),

                // Username
                const Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan username',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Asal Sekolah
                const Text(
                  'Asal Sekolah',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: sekolahController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: SMAN 1 Jakarta',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Nomor HP
                const Text(
                  'Nomor Handphone / WhatsApp',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: hpController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 081234567890',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Password Baru (Opsional)
                const Text(
                  'Ubah Password (Kosongkan jika tidak ingin mengubah)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password baru minimal 6 karakter',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                                updatePayload['password'] = passwordController
                                    .text
                                    .trim();
                              }

                              await DashboardService.updateStudentProfile(
                                updatePayload,
                              );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              _loadProfile();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF059669),
                                    content: Text(
                                      'Profil berhasil diperbarui! 🎉',
                                    ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _blue = Color(0xFF007FBE);
  static const _ink = Color(0xFF12233F);
  static const _muted = Color(0xFF465673);
  static const _bg = Color(0xFFF0F6FF);

  String _value(
    Map<String, dynamic> data,
    String key, [
    String fallback = '-',
  ]) {
    final value = data[key]?.toString().trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  Map<String, dynamic> _map(String key) =>
      Map<String, dynamic>.from(_profileData?[key] as Map? ?? {});

  Text _text(
    String text, {
    double size = 14,
    Color color = _ink,
    FontWeight weight = FontWeight.w800,
    TextAlign? align,
  }) => Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: 1.35,
    ),
  );

  BoxDecoration _card({Color color = Colors.white, double radius = 32}) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFDCEFFF)),
        boxShadow: const [
          BoxShadow(color: Color(0xFFB2E7FC), offset: Offset(0, 4)),
        ],
      );

  Widget _pill(Widget child, {Color color = Colors.white}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(30),
    ),
    child: child,
  );

  Widget _avatar(Map<String, dynamic> user, {double size = 94}) {
    final url = ApiConstants.resolveMediaUrl(user['foto_profil']?.toString());
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFF67D7FC)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3340B4DB),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: url == null
            ? Image.asset(
                'assets/images/auth/login-illustration.png',
                fit: BoxFit.cover,
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => Container(
                  color: const Color(0xFFDDF3FF),
                  alignment: Alignment.center,
                  child: _text(_value(user, 'nama', 'S')[0], size: 32),
                ),
              ),
      ),
    );
  }

  Future<void> _sound(bool value) async {
    await PreferencesService.setSoundEnabled(value);
    await AudioService.syncPreferences();
    if (mounted) setState(() => _isSoundEnabled = value);
  }

  void _openQr(Map<String, dynamic> user) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x6612233F),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: StudentQrSheet(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _blue)),
      );
    }
    if (_error != null || _profileData == null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: _blue),
                const SizedBox(height: 12),
                _text('Gagal memuat profil'),
                const SizedBox(height: 8),
                _text(
                  _error ?? 'Data belum tersedia',
                  size: 12,
                  align: TextAlign.center,
                ),
                TextButton(
                  onPressed: _loadProfile,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final user = _map('user');
    final rank = _map('rank');
    final stats = _map('stats');
    final achievements = (_profileData?['achievements'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final points = _value(rank, 'current_points', '0');
    final next = _value(rank, 'next_points', '100');
    final progress = ((num.tryParse('${rank['percent']}') ?? 0) / 100).clamp(
      0.0,
      1.0,
    );
    final level = _value(rank, 'level', _value(user, 'level', '-'));

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.nunitoSansTextTheme(Theme.of(context).textTheme),
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: _blue),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: RefreshIndicator(
          onRefresh: _loadProfile,
          color: _blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(user, stats, points),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFAEE3F9), Color(0xFFE6F3FF)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          _pill(
                            _text(
                              '👋 Halo, ${_value(user, 'nama', 'Siswa')}!',
                              color: _blue,
                              size: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _avatar(user),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: _blue,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _isPickingPhoto
                                        ? null
                                        : () => _changePhoto(user),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.photo_camera_outlined,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _text(_value(user, 'nama', 'Siswa'), size: 23),
                          _text(
                            '@${_value(user, 'username', 'siswa')}',
                            size: 12,
                            color: _blue,
                          ),
                          const SizedBox(height: 10),
                          _pill(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  size: 16,
                                  color: _blue,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: _text(
                                    '${_value(user, 'nama_jenjang')} • ${_value(user, 'asal_sekolah')}',
                                    size: 10,
                                    align: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _button(
                            'Edit Profil',
                            Icons.edit_outlined,
                            () => _showEditProfileSheet(user),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 38),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: _card(),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _stat(
                                      Icons.emoji_events_rounded,
                                      _value(stats, 'peringkat_kelas', '-'),
                                      'Juara Kelas',
                                      const Color(0xFFFFF9EC),
                                      const Color(0xFF946B00),
                                    ),
                                    const SizedBox(width: 8),
                                    _stat(
                                      Icons.rocket_launch_rounded,
                                      level == '-'
                                          ? _value(
                                              rank,
                                              'current_rank',
                                              'Pemula',
                                            )
                                          : 'Lv. $level',
                                      'Petualang',
                                      const Color(0xFFE0F3FF),
                                      _blue,
                                    ),
                                    const SizedBox(width: 8),
                                    _stat(
                                      Icons.bolt_rounded,
                                      points,
                                      'Bintang XP',
                                      const Color(0xFFEFF4FF),
                                      const Color(0xFF2455E6),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.rocket_launch_outlined,
                                      size: 15,
                                      color: _blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: _text(
                                        rank['is_max'] == true
                                            ? 'Level tertinggi tercapai!'
                                            : 'Menuju level berikutnya',
                                        size: 11,
                                      ),
                                    ),
                                    _text(
                                      '$points / $next XP',
                                      size: 10,
                                      color: _blue,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    height: 11,
                                    child: LayoutBuilder(
                                      builder: (_, c) => Stack(
                                        children: [
                                          Container(
                                            color: const Color(0xFFDCEFFC),
                                          ),
                                          Container(
                                            width: c.maxWidth * progress,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF00A5ED),
                                                  Color(0xFF51CDF4),
                                                  Color(0xFFFFC832),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _medals(achievements),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                color: _blue,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              _text('Data & Dokumen Siswa', size: 16),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _details(
                            'Data Pribadi',
                            'Nama Lengkap, Username, & NISN',
                            Icons.person_outline,
                            {
                              'Nama Lengkap': _value(user, 'nama'),
                              'NISN': _value(user, 'nisn'),
                              'Username': _value(user, 'username'),
                            },
                          ),
                          const SizedBox(height: 10),
                          _details(
                            'Data Pendidikan',
                            'Jenjang, Sekolah, & Rombel Kelas',
                            Icons.school_outlined,
                            {
                              'Jenjang': _value(user, 'nama_jenjang'),
                              'Sekolah': _value(user, 'asal_sekolah'),
                              'Kelas': _value(user, 'kelas'),
                            },
                          ),
                          const SizedBox(height: 10),
                          _details(
                            'Kontak & Keluarga',
                            'Email, Nomor HP, & Orang Tua',
                            Icons.phone_outlined,
                            _familyDetails(user),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: _card(color: const Color(0xFFD8F3FC)),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 24,
                                  child: Icon(
                                    Icons.badge_outlined,
                                    color: _blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _text('Kartu Presensi Siswa', size: 15),
                                      const SizedBox(height: 4),
                                      _text(
                                        'Siap mencatat kehadiranmu? Buka QR Code presensimu di sini!',
                                        size: 11,
                                        color: _muted,
                                        weight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _button(
                                  'Lihat QR',
                                  Icons.qr_code_rounded,
                                  () => _openQr(user),
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          _text('Pengaturan Aplikasi', size: 16),
                          const SizedBox(height: 10),
                          Container(
                            decoration: _card(radius: 18),
                            child: Column(
                              children: [
                                _setting(
                                  'Efek Suara Kuis',
                                  'Suara tombol dan chime notifikasi kuis',
                                  Icons.volume_up_outlined,
                                  _isSoundEnabled,
                                  _sound,
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE5F0FA),
                                ),
                                _setting(
                                  'Getaran (Haptic Feedback)',
                                  'Getar lembut saat memilih jawaban kuis',
                                  Icons.vibration_rounded,
                                  _isHapticEnabled,
                                  (value) async {
                                    await PreferencesService.setHapticEnabled(
                                      value,
                                    );
                                    await AudioService.syncPreferences();
                                    if (value) {
                                      await AudioService.triggerHaptic();
                                    }
                                    if (mounted) {
                                      setState(() => _isHapticEnabled = value);
                                    }
                                  },
                                  green: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  showLogoutConfirmationDialog(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF454D),
                                side: const BorderSide(
                                  color: Color(0xFFFF9EA6),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text(
                                'Keluar dari Akun',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(
    Map<String, dynamic> user,
    Map<String, dynamic> stats,
    String points,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFD9ECFC),
          child: Icon(Icons.school_outlined, color: _blue, size: 22),
        ),
        const SizedBox(width: 8),
        Expanded(child: _text('Arrava', color: _blue, size: 17)),
        _pill(_text('🔥 ${_value(stats, 'streak', '0')}', size: 11)),
        const SizedBox(width: 5),
        _pill(_text('★ $points', size: 11, color: const Color(0xFFAA7900))),
        IconButton(
          tooltip: 'Efek suara',
          visualDensity: VisualDensity.compact,
          onPressed: () => _sound(!_isSoundEnabled),
          icon: Icon(
            _isSoundEnabled
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined,
            color: _blue,
            size: 21,
          ),
        ),
        CircleAvatar(
          radius: 17,
          backgroundColor: _blue,
          child: Text(
            _value(user, 'nama', 'S')[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  Widget _button(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool compact = false,
  }) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(color: Color(0xFF00628E), offset: Offset(0, 4)),
      ],
    ),
    child: ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 20,
          vertical: 13,
        ),
        minimumSize: const Size(0, 42),
        shape: const StadiumBorder(),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );

  Widget _stat(
    IconData icon,
    String value,
    String label,
    Color bg,
    Color color,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 5),
          _text(value, size: 17, color: color, align: TextAlign.center),
          const SizedBox(height: 5),
          _text(label, size: 10, color: _muted),
        ],
      ),
    ),
  );

  Map<String, String> _familyDetails(Map<String, dynamic> user) {
    final values = <String, String>{
      'Email Siswa': _value(user, 'email'),
      'Nomor HP Siswa': _value(user, 'nomor_hp'),
    };
    final parents = (_profileData?['orang_tua'] as List? ?? [])
        .whereType<Map>()
        .map((parent) => Map<String, dynamic>.from(parent))
        .toList();
    if (parents.isEmpty) {
      values.addAll({
        'Nama Orang Tua': _value(user, 'nama_orang_tua', 'Belum tersedia'),
        'Nomor HP Orang Tua': _value(
          user,
          'nomor_hp_orang_tua',
          'Belum tersedia',
        ),
        'Email Orang Tua': _value(user, 'email_orang_tua', 'Belum tersedia'),
      });
    } else {
      for (var i = 0; i < parents.length; i++) {
        final suffix = parents.length > 1 ? ' ${i + 1}' : '';
        values['Nama Orang Tua$suffix'] = _value(
          parents[i],
          'nama',
          'Belum diisi',
        );
        values['Nomor HP Orang Tua$suffix'] = _value(
          parents[i],
          'nomor_hp',
          'Belum diisi',
        );
        values['Email Orang Tua$suffix'] = _value(
          parents[i],
          'email',
          'Belum diisi',
        );
      }
    }
    return values;
  }

  Widget _details(
    String title,
    String subtitle,
    IconData icon,
    Map<String, String> values,
  ) => Container(
    decoration: _card(),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      iconColor: _blue,
      collapsedIconColor: _blue,
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: const Color(0xFFE0F3FF),
        child: Icon(icon, size: 19, color: _blue),
      ),
      title: _text(title, size: 14),
      subtitle: _text(
        subtitle,
        size: 10,
        color: _muted,
        weight: FontWeight.w500,
      ),
      children: values.entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: _text(
                      e.key,
                      size: 11,
                      color: _muted,
                      weight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: _text(e.value, size: 12, align: TextAlign.right),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _medals(List<Map<String, dynamic>> achievements) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _card(),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.workspace_premium, color: _blue, size: 19),
            const SizedBox(width: 4),
            Expanded(child: _text('Koleksi Medali', size: 16)),
            _pill(
              _text('${achievements.length} Terbuka', size: 10, color: _blue),
              color: const Color(0xFFE0F3FF),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (achievements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 34,
                  color: _blue,
                ),
                const SizedBox(height: 8),
                _text('Petualangan medalimu dimulai di sini!', size: 12),
                _text(
                  'Selesaikan modul dan kuis untuk meraih medali.',
                  size: 10,
                  color: _muted,
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (_, c) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements
                  .take(4)
                  .map(
                    (a) =>
                        SizedBox(width: (c.maxWidth - 8) / 2, child: _medal(a)),
                  )
                  .toList(),
            ),
          ),
        if (achievements.isNotEmpty)
          TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _text('Semua Medali', size: 20),
                      const SizedBox(height: 16),
                      ...achievements.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _medal(a),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: Text(
              'Lihat Semua Medali (${achievements.length}) ›',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
      ],
    ),
  );

  Widget _medal(Map<String, dynamic> a) {
    final image = ApiConstants.resolveMediaUrl(a['gambar_url']?.toString());
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFDCEFFF)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFBCEAFF),
            child: image == null
                ? const Icon(
                    Icons.workspace_premium_outlined,
                    size: 20,
                    color: _blue,
                  )
                : ClipOval(
                    child: Image.network(
                      image,
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stack) =>
                          const Icon(Icons.workspace_premium, color: _blue),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(_value(a, 'nama', 'Medali'), size: 10),
                _text(
                  _value(a, 'tanggal', ''),
                  size: 9,
                  color: _muted,
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _setting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool green = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: green
              ? const Color(0xFFEDFFF6)
              : const Color(0xFFEAF7FF),
          child: Icon(
            icon,
            color: green ? const Color(0xFF00B987) : _blue,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text(title, size: 13),
              const SizedBox(height: 2),
              _text(subtitle, size: 11, color: _muted, weight: FontWeight.w500),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: _blue,
          activeThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE1E7EF),
          inactiveThumbColor: const Color(0xFF78838D),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ],
    ),
  );
}
