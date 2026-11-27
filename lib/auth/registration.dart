import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/network/api_client.dart';
import '../shared/widgets/arrava_logo.dart';

const _registration = '/pendaftaran';
const _otp = '$_registration/otp';

Future<dynamic> _post(String path, Map<String, dynamic> body) =>
    ApiClient.post(path, body: body, authenticated: false);

String _message(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _studentForm = GlobalKey<FormState>();
  final _parentForm = GlobalKey<FormState>();
  final _values = <String, String>{};
  late Future<Map<String, String>> _levels;
  String? _level;
  String? _error;
  bool _busy = false;
  bool _showParent = false;
  bool _samePassword = true;

  @override
  void initState() {
    super.initState();
    _levels = _loadLevels();
  }

  Future<Map<String, String>> _loadLevels() async {
    final response = await ApiClient.get(
      '$_registration/jenjang',
      authenticated: false,
    );
    return {
      for (final level in response['data'] as List)
        level['id_jenjang'].toString(): level['nama_tipe'].toString(),
    };
  }

  void _showStep({required bool parent}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _showParent = parent;
      _error = null;
    });
  }

  void _next() {
    if (_level == null || !_studentForm.currentState!.validate()) return;
    _showStep(parent: true);
  }

  Future<void> _submit() async {
    if (_busy || !_parentForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await _post(_registration, {
        for (final entry in _values.entries)
          if (entry.value.isNotEmpty &&
              (entry.key != 'password_orangtua' || !_samePassword))
            entry.key: entry.value,
        'id_jenjang': _level,
      });
      final id = response['registration_id'];
      final email = response['email'];
      if (response['success'] != true || id is! String || email is! String) {
        throw Exception('Respons pendaftaran tidak lengkap.');
      }
      if (!mounted) return;
      final confirmation = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => RegistrationOtpScreen(
            registrationId: id,
            email: email,
            retryAfter: _delay(response['retry_after']),
          ),
        ),
      );
      if (!mounted || confirmation == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(confirmation)));
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    String key,
    String label, {
    bool optional = false,
    TextInputType? keyboard,
    String? Function(String)? validate,
  }) {
    final password = key.startsWith('password');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: _values[key],
        enabled: !_busy,
        obscureText: password,
        keyboardType: keyboard,
        maxLength: key == 'nisn' ? 10 : null,
        inputFormatters: [
          if (key == 'nisn') FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) => _values[key] = password ? value : value.trim(),
        validator: (input) {
          final value = password ? input ?? '' : input?.trim() ?? '';
          if (value.isEmpty)
            return optional ? validate?.call(value) : '$label wajib diisi.';
          if (keyboard == TextInputType.emailAddress &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
            return 'Masukkan alamat email yang valid.';
          }
          if (keyboard == TextInputType.phone &&
              !RegExp(r'^[0-9+\-\s]{10,20}$').hasMatch(value)) {
            return 'Masukkan nomor HP yang valid (10–20 karakter).';
          }
          if (password && value.length < 8) return 'Minimal 8 karakter.';
          return validate?.call(value);
        },
      ),
    );
  }

  bool _hasValue(String key) => _values[key]?.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) => _RegistrationPage(
    title: 'Daftar sebagai siswa',
    step: _showParent ? 2 : 1,
    canPop: !_busy && !_showParent,
    onBack: _busy || !_showParent ? null : () => _showStep(parent: false),
    children: [_showParent ? _buildParentForm() : _buildStudentForm()],
  );

  Widget _buildStudentForm() => Form(
    key: _studentForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          'nama',
          'Nama siswa',
          validate: (value) => RegExp(r'^[a-zA-Z\s]{2,255}$').hasMatch(value)
              ? null
              : 'Masukkan nama siswa dengan huruf dan spasi.',
        ),
        _field('email', 'Email siswa', keyboard: TextInputType.emailAddress),
        _field(
          'nisn',
          'NISN',
          keyboard: TextInputType.number,
          validate: (value) =>
              value.length == 10 ? null : 'NISN harus 10 digit.',
        ),
        _field(
          'nomor_handphone',
          'Nomor HP siswa',
          keyboard: TextInputType.phone,
        ),
        FutureBuilder(
          future: _levels,
          builder: (context, snapshot) {
            final levels = snapshot.data;
            if (levels == null || levels.isEmpty) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }
              return TextButton(
                onPressed: () => setState(() => _levels = _loadLevels()),
                child: const Text('Jenjang gagal dimuat. Coba lagi'),
              );
            }
            return DropdownButtonFormField<String>(
              initialValue: _level,
              decoration: const InputDecoration(
                labelText: 'Jenjang pendidikan',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final level in levels.entries)
                  DropdownMenuItem(value: level.key, child: Text(level.value)),
              ],
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _level = value),
              validator: (value) =>
                  value == null ? 'Pilih jenjang pendidikan.' : null,
            );
          },
        ),
        const SizedBox(height: 12),
        _field('password', 'Kata sandi siswa'),
        _field(
          'password_confirmation',
          'Konfirmasi kata sandi siswa',
          validate: (value) =>
              value == _values['password'] ? null : 'Kata sandi tidak cocok.',
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _level == null ? null : _next,
          child: const Text('Lanjut: Data Orang Tua'),
        ),
      ],
    ),
  );

  Widget _buildParentForm() => Form(
    key: _parentForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Isi data orang tua atau wali jika ingin menambahkan akun pendamping. Kode verifikasi dikirim ke email siswa.',
        ),
        const SizedBox(height: 16),
        _field(
          'nama_orangtua',
          'Nama orang tua',
          optional: true,
          validate: (value) {
            if (value.isEmpty &&
                (_hasValue('email_orangtua') ||
                    _hasValue('nomor_hp_orangtua') ||
                    (!_samePassword && _hasValue('password_orangtua')))) {
              return 'Nama orang tua wajib diisi.';
            }
            return value.length == 1 ? 'Minimal 2 karakter.' : null;
          },
        ),
        _field(
          'email_orangtua',
          'Email orang tua',
          optional: true,
          keyboard: TextInputType.emailAddress,
          validate: (value) {
            if (value.isEmpty)
              return _hasValue('nama_orangtua')
                  ? 'Email orang tua wajib diisi.'
                  : null;
            return value.toLowerCase() == _values['email']?.toLowerCase()
                ? 'Gunakan email yang berbeda dari email siswa.'
                : null;
          },
        ),
        _field(
          'nomor_hp_orangtua',
          'Nomor HP orang tua',
          optional: true,
          keyboard: TextInputType.phone,
          validate: (value) => value.isEmpty && _hasValue('nama_orangtua')
              ? 'Nomor HP orang tua wajib diisi.'
              : null,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Gunakan kata sandi yang sama dengan siswa'),
          value: _samePassword,
          onChanged: _busy
              ? null
              : (checked) => setState(() => _samePassword = checked ?? true),
        ),
        if (!_samePassword)
          _field(
            'password_orangtua',
            'Kata sandi orang tua',
            optional: true,
            validate: (value) => value.isEmpty && _hasValue('nama_orangtua')
                ? 'Masukkan kata sandi orang tua.'
                : null,
          ),
        if (_error case final error?) _Status(error),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? 'Memproses…' : 'Kirim kode ke email siswa'),
        ),
        TextButton(
          onPressed: _busy ? null : () => _showStep(parent: false),
          child: const Text('Kembali ke data siswa'),
        ),
      ],
    ),
  );
}

Duration _delay(Object? seconds) =>
    Duration(seconds: (int.tryParse('$seconds') ?? 60).clamp(0, 86400));

class RegistrationOtpScreen extends StatefulWidget {
  const RegistrationOtpScreen({
    super.key,
    required this.registrationId,
    required this.email,
    required this.retryAfter,
    this.elapsed,
  });

  final String registrationId;
  final String email;
  final Duration retryAfter;
  final Duration Function()? elapsed;

  @override
  State<RegistrationOtpScreen> createState() => _RegistrationOtpScreenState();
}

class _RegistrationOtpScreenState extends State<RegistrationOtpScreen> {
  final _code = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _stopwatch = Stopwatch()..start();
  Duration _resendAt = Duration.zero;
  Timer? _timer;
  bool _busy = false;
  bool _expired = false;
  String? _status;
  bool _hasError = false;

  Duration get _elapsed => widget.elapsed?.call() ?? _stopwatch.elapsed;

  int get _secondsLeft =>
      ((_resendAt - _elapsed).inMicroseconds / Duration.microsecondsPerSecond)
          .ceil()
          .clamp(0, 86400);

  @override
  void initState() {
    super.initState();
    _startCooldown(widget.retryAfter);
  }

  void _startCooldown(Duration delay) {
    _timer?.cancel();
    _resendAt = _elapsed + delay;
    if (delay <= Duration.zero) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) timer.cancel();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _code.dispose();
    super.dispose();
  }

  Future<void> _request({required bool resend}) async {
    if (_busy || _expired) return;
    if (resend ? _secondsLeft > 0 : !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final response = await _post(resend ? '$_otp/kirim-ulang' : _otp, {
        'registration_id': widget.registrationId,
        if (!resend) 'code': _code.text,
      });
      if (!mounted) return;
      if (response['success'] != true) {
        throw Exception('Respons verifikasi tidak lengkap.');
      }
      if (resend) {
        _startCooldown(_delay(response['retry_after']));
        _form.currentState!.reset();
        _code.clear();
        _status = 'Kode baru sudah dikirim.';
        _hasError = false;
      } else {
        Navigator.of(context).pop(
          response['message']?.toString() ??
              'Pendaftaran berhasil. Silakan masuk.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      if (error is ApiResponseException) {
        _expired = error.statusCode == 410 || error.statusCode == 409;
        if (resend && error.retryAfter != null) {
          _startCooldown(_delay(error.retryAfter));
        }
      }
      _status = _message(error);
      _hasError = true;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _RegistrationPage(
    title: 'Daftar sebagai siswa',
    step: 3,
    canPop: !_busy,
    children: [
      Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Kode 6 digit dikirim ke '),
            TextSpan(
              text: widget.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '. Kode berlaku selama 5 menit.'),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Form(
        key: _form,
        child: TextFormField(
          controller: _code,
          enabled: !_busy && !_expired,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _request(resend: false),
          validator: (value) =>
              value?.length == 6 ? null : 'Masukkan kode 6 digit.',
          decoration: const InputDecoration(
            labelText: 'Kode verifikasi',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      if (_status case final status?) _Status(status, isError: _hasError),
      ElevatedButton(
        onPressed: _busy || _expired ? null : () => _request(resend: false),
        child: Text(_busy ? 'Memproses…' : 'Verifikasi kode'),
      ),
      TextButton(
        onPressed: _busy || _expired || _secondsLeft > 0
            ? null
            : () => _request(resend: true),
        child: const Text('Kirim ulang kode'),
      ),
      if (!_expired && _secondsLeft > 0)
        Text(
          'Kirim ulang tersedia dalam $_secondsLeft detik.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      TextButton(
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
        child: const Text('Kembali ke pendaftaran'),
      ),
    ],
  );
}

class _Status extends StatelessWidget {
  const _Status(this.message, {this.isError = true});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Theme.of(context).colorScheme.error : null,
        ),
      ),
    ),
  );
}

class _RegistrationPage extends StatelessWidget {
  const _RegistrationPage({
    required this.title,
    required this.step,
    required this.children,
    required this.canPop,
    this.onBack,
  });

  final String title;
  final int step;
  final List<Widget> children;
  final bool canPop;
  final VoidCallback? onBack;

  static const _labels = ['Data siswa', 'Orang tua', 'Verifikasi'];
  static const _headings = [
    'Informasi akun siswa',
    'Informasi akun orang tua',
    'Verifikasi email siswa',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack?.call();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        backgroundColor: colors.primaryContainer.withValues(alpha: 0.22),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                key: ValueKey(step),
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    color: colors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const ArravaLogo(size: 36),
                                const SizedBox(width: 8),
                                Text(
                                  'Arrava',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            label: 'Langkah $step dari 3',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (
                                  var index = 0;
                                  index < _labels.length;
                                  index++
                                )
                                  Expanded(
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 13,
                                          backgroundColor: index < step
                                              ? colors.primary
                                              : colors.surfaceContainerHighest,
                                          foregroundColor: index < step
                                              ? colors.onPrimary
                                              : colors.onSurfaceVariant,
                                          child: index + 1 < step
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                )
                                              : Text('${index + 1}'),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _labels[index],
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _headings[step - 1],
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...children,
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
    );
  }
}
