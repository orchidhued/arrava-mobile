import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'student_qr_sheet.dart';
import '../leaderboard/leaderboard_screen.dart';

import '../../core/constants/api_constants.dart';
import '../../core/services/audio_service.dart';
import '../../core/storage/preferences_service.dart';
import '../../services/dashboard_service.dart';
import '../../shared/utils/logout_dialog.dart';

class StudentProfilePage extends StatefulWidget {
  final ValueChanged<String>? onHeroThemeChanged;

  const StudentProfilePage({super.key, this.onHeroThemeChanged});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  bool _isLoading = true;
  bool _isPickingPhoto = false;
  bool _isUpdatingHeroTheme = false;
  int _heroThemeRevision = 0;
  String? _error;
  Map<String, dynamic>? _profileData;
  String _heroTheme = 'samudra';
  bool _isSoundEnabled = true;
  bool _isHapticEnabled = true;
  int _photoRevision = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final revAtStart = _heroThemeRevision;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sound = await PreferencesService.isSoundEnabled();
      final haptic = await PreferencesService.isHapticEnabled();
      final cachedTheme = await PreferencesService.getHeroTheme();
      final data = await DashboardService.fetchStudentProfile();
      final apiTheme = data['user'] is Map
          ? (data['user'] as Map)['hero_theme']
          : null;
      final resolvedTheme = apiTheme != null
          ? DashboardService.normalizeHeroTheme(apiTheme)
          : cachedTheme;
      if (mounted) {
        setState(() {
          _isSoundEnabled = sound;
          _isHapticEnabled = haptic;
          _profileData = data;
          if (revAtStart == _heroThemeRevision) {
            _heroTheme = resolvedTheme;
          } else if (data['user'] is Map) {
            (data['user'] as Map)['hero_theme'] = _heroTheme;
          }
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

  Future<void> _selectHeroTheme(String targetTheme) async {
    final normalized = DashboardService.normalizeHeroTheme(targetTheme);
    if (_isUpdatingHeroTheme || normalized == _heroTheme) return;

    setState(() => _isUpdatingHeroTheme = true);
    try {
      final result = await DashboardService.updateStudentHeroTheme(normalized);
      final updatedTheme = DashboardService.normalizeHeroTheme(
        result['hero_theme'] ?? normalized,
      );
      if (mounted) {
        setState(() {
          _heroThemeRevision++;
          _heroTheme = updatedTheme;
          final userMap = _profileData?['user'];
          if (userMap is Map<String, dynamic>) {
            userMap['hero_theme'] = updatedTheme;
          } else if (userMap is Map) {
            _profileData!['user'] = Map<String, dynamic>.from(userMap)
              ..['hero_theme'] = updatedTheme;
          }
          _isUpdatingHeroTheme = false;
        });
        widget.onHeroThemeChanged?.call(updatedTheme);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  'Tema hero dashboard berhasil diperbarui.',
            ),
            backgroundColor: _blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdatingHeroTheme = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFFF454D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _changePhoto(Map<String, dynamic> user) async {
    if (_isPickingPhoto) return;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                'Pilih Sumber Foto Profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: _blue),
                ),
                title: const Text(
                  'Ambil dari Kamera',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: const Text(
                  'Foto langsung menggunakan kamera HP',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 6),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: _blue),
                ),
                title: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: const Text(
                  'Pilih foto dari penyimpanan galeri',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    setState(() => _isPickingPhoto = true);
    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo == null || !mounted) return;
      if (await photo.length() > 2 * 1024 * 1024) {
        throw Exception(
          'Ukuran foto maksimal 2 MB. Pilih foto yang lebih kecil.',
        );
      }
      final bytes = await photo.readAsBytes();
      final extension = _photoExtension(bytes) ?? 'jpg';
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
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      setState(() {
        _profileData = updatedProfile;
        _photoRevision = DateTime.now().millisecondsSinceEpoch;
      });
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
    final rawUrl =
        (user['foto_profil'] ?? user['foto_profil_url'] ?? user['foto'])
            ?.toString();
    final resolvedUrl = ApiConstants.resolveMediaUrl(rawUrl);
    final url = resolvedUrl != null
        ? (resolvedUrl.contains('?')
              ? '$resolvedUrl&v=$_photoRevision'
              : '$resolvedUrl?v=$_photoRevision')
        : null;
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
            ? Container(
                color: const Color(0xFFDDF3FF),
                alignment: Alignment.center,
                child: _text(
                  _value(user, 'nama', 'S')[0].toUpperCase(),
                  size: 32,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) {
                  debugPrint(
                    '[AVATAR ERROR] Failed loading image from: $url | Error: $error',
                  );
                  return Container(
                    color: const Color(0xFFDDF3FF),
                    alignment: Alignment.center,
                    child: _text(
                      _value(user, 'nama', 'S')[0].toUpperCase(),
                      size: 32,
                    ),
                  );
                },
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
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _button(
                                'Edit Profil',
                                Icons.edit_outlined,
                                () => _showEditProfileSheet(user),
                              ),
                              _heroQuickToggleButton(),
                            ],
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
                                      'Peringkat',
                                      const Color(0xFFFFF9EC),
                                      const Color(0xFF946B00),
                                      onTap: () {
                                        final jId = int.tryParse(
                                          user['id_jenjang']?.toString() ?? '',
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LeaderboardScreen(
                                              initialJenjangId: jId,
                                            ),
                                          ),
                                        );
                                      },
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
                                      'Bintang EXP',
                                      const Color(0xFFEFF4FF),
                                      const Color(0xFF2455E6),
                                      customIcon: Image.asset(
                                        'assets/widget/exp.png',
                                        width: 20,
                                        height: 20,
                                        filterQuality: FilterQuality.none,
                                      ),
                                      onTap: () {
                                        final jId = int.tryParse(
                                          user['id_jenjang']?.toString() ?? '',
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LeaderboardScreen(
                                              initialJenjangId: jId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                // Header EXP status (persis Web profil_siswa.blade.php)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rank['is_max'] == true
                                            ? 'Peringkat Tertinggi (MAX TIER) 👑'
                                            : 'Menuju ${rank['next_rank'] ?? 'Lanjutan'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: rank['is_max'] == true
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF465673),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      rank['is_max'] == true
                                          ? 'MAX ($points EXP)'
                                          : '$points / $next EXP',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF082765),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Baris EXP Bar dengan Icon Widget exp.png di sebelahnya
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/widget/exp.png',
                                      width: 24,
                                      height: 24,
                                      filterQuality: FilterQuality.none,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDDF3FF),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFB2E7FC),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: LayoutBuilder(
                                            builder: (_, c) => Stack(
                                              children: [
                                                Container(
                                                  width:
                                                      c.maxWidth *
                                                      progress.clamp(0.0, 1.0),
                                                  decoration:
                                                      const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFFFBBF24,
                                                                ),
                                                                Color(
                                                                  0xFFFB923C,
                                                                ),
                                                                Color(
                                                                  0xFFF59E0B,
                                                                ),
                                                              ],
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(progress * 100).round()}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Subtitle / Footer Keterangan Sisa EXP
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rank['is_max'] == true
                                            ? 'Luar biasa! Semua tingkat terbuka.'
                                            : 'Kurang ${rank['points_needed'] ?? 0} EXP lagi',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: rank['is_max'] == true
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF72839E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(progress * 100).round()}% menuju pangkat baru',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF72839E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildHeroThemeSection(),
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
    Color color, {
    VoidCallback? onTap,
    Widget? customIcon,
  }) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
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
              child: customIcon ?? Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 5),
            _text(value, size: 17, color: color, align: TextAlign.center),
            const SizedBox(height: 5),
            _text(label, size: 10, color: _muted),
          ],
        ),
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

  Widget _heroQuickToggleButton() {
    final nextTheme = _heroTheme == 'galaksi' ? 'samudra' : 'galaksi';
    final nextShort = nextTheme == 'galaksi' ? 'Galaksi' : 'Samudra';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0xFFB2E7FC), offset: Offset(0, 4)),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: _isUpdatingHeroTheme
            ? null
            : () => _selectHeroTheme(nextTheme),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF8FCFF),
          foregroundColor: const Color(0xFF007FBE),
          side: const BorderSide(color: Color(0xFF8FD6FA)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          minimumSize: const Size(0, 42),
          shape: const StadiumBorder(),
        ),
        icon: _isUpdatingHeroTheme
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2, color: _blue),
              )
            : Icon(
                nextTheme == 'galaksi'
                    ? Icons.auto_awesome_rounded
                    : Icons.water_rounded,
                size: 16,
              ),
        label: Text(
          'Ganti Hero ke $nextShort',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildHeroThemeSection() {
    final activeLabel = _heroTheme == 'galaksi'
        ? 'Galaksi Piksel'
        : 'Samudra Piksel';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(radius: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _text('Tema Hero Dashboard 🎨', size: 15),
                    const SizedBox(height: 2),
                    _text(
                      'Pilih suasana hero dashboard yang tampil di halaman beranda.',
                      size: 11,
                      color: _muted,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F3FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB2E7FC)),
                ),
                child: Text(
                  activeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final useRow = constraints.maxWidth >= 460;
              final samudraCard = _buildHeroThemeOptionCard(
                themeKey: 'samudra',
                title: 'Samudra Piksel',
                description: 'Suasana bawah laut dengan ikan piksel berenang.',
                actionLabel: 'Gunakan Samudra →',
                bgColor: const Color(0xFF0C4A6E),
                previewBuilder: () => Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/widget/cards/underwaterHeroSection.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      filterQuality: FilterQuality.none,
                    ),
                    Positioned(
                      right: 14,
                      top: 22,
                      child: Image.asset(
                        'assets/widget/cards/fish3.webp',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                    Positioned(
                      left: 18,
                      bottom: 14,
                      child: Image.asset(
                        'assets/widget/cards/fish1.webp',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ],
                ),
              );

              final galaksiCard = _buildHeroThemeOptionCard(
                themeKey: 'galaksi',
                title: 'Galaksi Piksel',
                description: 'Luar angkasa dengan planet mengorbit & asteroid interaktif.',
                actionLabel: 'Gunakan Galaksi →',
                bgColor: const Color(0xFF05060F),
                previewBuilder: () => Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/widget/cards/herosection/herosection2/BackgroundSpace.webp',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                    ),
                    Image.asset(
                      'assets/widget/cards/herosection/herosection2/layer4_celestial.webp',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Image.asset(
                        'assets/widget/cards/herosection/herosection2/prop-planet-big.webp',
                        width: 34,
                        height: 34,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 14,
                      child: Image.asset(
                        'assets/widget/cards/herosection/herosection2/asteroid-1.webp',
                        width: 26,
                        height: 22,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ],
                ),
              );

              if (useRow) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: samudraCard),
                    const SizedBox(width: 12),
                    Expanded(child: galaksiCard),
                  ],
                );
              }
              return Column(
                children: [
                  samudraCard,
                  const SizedBox(height: 12),
                  galaksiCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroThemeOptionCard({
    required String themeKey,
    required String title,
    required String description,
    required String actionLabel,
    required Color bgColor,
    required Widget Function() previewBuilder,
  }) {
    final isActive = _heroTheme == themeKey;

    return Material(
      color: isActive ? const Color(0xFFF0F9FF) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _isUpdatingHeroTheme ? null : () => _selectHeroTheme(themeKey),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? _blue : const Color(0xFFDCEFFF),
              width: isActive ? 2 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 92,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: bgColor,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        previewBuilder(),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF059669)
                                  : Colors.black.withValues(alpha: 0.58),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFF6EE7B7)
                                    : Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              isActive ? '✓ Aktif' : 'Pilih',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    isActive ? 'Sedang Digunakan' : actionLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isActive ? const Color(0xFF059669) : _blue,
                    ),
                  ),
                  if (_isUpdatingHeroTheme && !isActive) ...[
                    const SizedBox(width: 6),
                    const SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: _blue,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
