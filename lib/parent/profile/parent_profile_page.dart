import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/utils/logout_dialog.dart';
import 'parent_password_form.dart';
import 'parent_profile_service.dart';

class ParentProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final ValueChanged<ParentProfile> onSaved;

  const ParentProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.onSaved,
  });

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  late Future<bool> _soundEnabled = PreferencesService.isSoundEnabled();

  ParentProfile? _profile;
  ({Uint8List bytes, String filename})? _pendingPhoto;
  bool _loading = true;
  bool _saving = false;
  bool _pickingPhoto = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _fillForm(ParentProfile profile) {
    _name.text = profile.name;
    _email.text = profile.email;
    _phone.text = profile.phone;
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ParentProfileService.load();
      if (!mounted) return;
      _fillForm(profile);
      setState(() => _profile = profile);
    } on ApiResponseException catch (error) {
      final message = switch (error.statusCode) {
        401 => 'Sesi login sudah berakhir. Masuk kembali untuk membuka profil.',
        403 => 'Profil ini hanya bisa dibuka dengan akun orang tua.',
        404 => 'Rute profil orang tua belum tersedia di server yang terhubung.',
        >= 200 && < 300 => 'Respons profil dari server tidak dapat dibaca.',
        _ => 'Server gagal memuat profil (HTTP ${error.statusCode}).',
      };
      if (mounted) setState(() => _error = message);
    } on FormatException {
      if (mounted) {
        setState(() => _error = 'Data profil belum dikirim oleh server.');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Profil gagal dimuat. Periksa koneksi ke server.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickPhoto() async {
    if (_saving || _pickingPhoto) return;
    setState(() {
      _pickingPhoto = true;
      _error = null;
    });

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      if (await image.length() > 2 * 1024 * 1024) {
        if (mounted) setState(() => _error = 'Ukuran foto maksimal 2 MB.');
        return;
      }
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() => _pendingPhoto = (bytes: bytes, filename: image.name));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Foto gagal dibuka.');
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_saving || _pickingPhoto || !_formKey.currentState!.validate()) return;
    final onSaved = widget.onSaved;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final profile = await ParentProfileService.save(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        photo: _pendingPhoto,
      );
      onSaved(profile);
      if (!mounted) return;
      _fillForm(profile);
      setState(() {
        _profile = profile;
        _pendingPhoto = null;
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan profil berhasil disimpan.')),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _avatar({Uint8List? preview, double radius = 29}) {
    final photo = _profile?.photo;
    final ImageProvider? image = preview != null
        ? MemoryImage(preview)
        : photo == null
        ? null
        : NetworkImage(photo);

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primary,
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, _) {},
      child: Icon(Icons.person_rounded, size: radius),
    );
  }

  Widget _accountSummary(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final email = _profile?.email ?? widget.email;
    final phone = _profile?.phone ?? '';

    return Card(
      color: const Color(0xFFF6FBFF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _avatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        'Orang Tua / Wali Murid',
                        style: theme.labelSmall?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _profile?.name ?? widget.name,
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (email.isNotEmpty)
                    _contactLine(Icons.mail_outline_rounded, email),
                  if (phone.isNotEmpty)
                    _contactLine(Icons.phone_outlined, phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactLine(IconData icon, String value) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.primary),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ],
  );

  Widget _profileForm(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_profile == null) {
      return Column(
        children: [
          Text(_error ?? 'Profil gagal dimuat.'),
          TextButton(onPressed: _loadProfile, child: const Text('Coba lagi')),
        ],
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              _avatar(preview: _pendingPhoto?.bytes, radius: 25),
              const SizedBox(width: 12),
              Flexible(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_pickingPhoto ? 'Membuka galeri…' : 'Pilih Foto'),
                  onPressed: _saving || _pickingPhoto ? null : _pickPhoto,
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _name,
            enabled: !_saving,
            maxLength: 100,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nama lengkap',
              counterText: '',
            ),
            validator: (value) => (value ?? '').trim().isEmpty
                ? 'Nama lengkap wajib diisi.'
                : null,
          ),
          TextFormField(
            controller: _email,
            enabled: !_saving,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) =>
                RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                    .hasMatch((value ?? '').trim())
                ? null
                : 'Masukkan alamat email yang valid.',
          ),
          TextFormField(
            controller: _phone,
            enabled: !_saving,
            maxLength: 20,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor HP (opsional)',
              counterText: '',
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          FilledButton(
            onPressed: _saving || _pickingPhoto ? null : _saveProfile,
            child: Text(_saving ? 'Menyimpan…' : 'Simpan Perubahan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Kelola akun orang tua dan preferensi aplikasi.'),
          const SizedBox(height: 14),
          _accountSummary(context),
          const SizedBox(height: 20),
          Text(
            'PENGATURAN AKUN',
            style: theme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ExpansionTile(
                  leading: const _SettingsIcon(Icons.person_outline_rounded),
                  title: const Text('Ubah Profil & Foto'),
                  maintainState: true,
                  childrenPadding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  children: [_profileForm(context)],
                ),
                const Divider(indent: 14, endIndent: 14),
                const ExpansionTile(
                  leading: _SettingsIcon(Icons.lock_outline_rounded),
                  title: Text('Keamanan & Kata Sandi'),
                  childrenPadding: EdgeInsets.fromLTRB(14, 4, 14, 14),
                  children: [ParentPasswordForm()],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: FutureBuilder<bool>(
              future: _soundEnabled,
              builder: (context, snapshot) => SwitchListTile(
                secondary: const _SettingsIcon(Icons.volume_up_outlined),
                title: const Text('Efek Suara Kuis'),
                value: snapshot.data ?? true,
                onChanged: !snapshot.hasData
                    ? null
                    : (value) async {
                        await PreferencesService.setSoundEnabled(value);
                        if (mounted) {
                          setState(() => _soundEnabled = Future.value(value));
                        }
                      },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saving
                ? null
                : () => showLogoutConfirmationDialog(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Keluar dari Akun'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE2DF),
              foregroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  final IconData icon;

  const _SettingsIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: AppColors.primaryDark),
      ),
    );
  }
}
