import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:arrava_mobile/admin/admin_shell.dart';
import 'package:arrava_mobile/core/storage/secure_storage.dart';
import 'package:arrava_mobile/screens/dashboard_screen.dart';
import 'package:arrava_mobile/services/auth_service.dart';

/* =====================================================================
   1. PENGATURAN (Gambar, Warna, dan Parameter Efek)
   ===================================================================== */

class FloatCfg {
  final int dur; // ms per naik-turun (4200, 3000)
  final double ax; // jarak geser kiri-kanan % (5, 4)
  final double ay; // jarak geser naik-turun % (12, 10)
  final double ph; // fase awal (0, 0.5)
  final double o; // opacity dasar (0.55, 1.0)
  final double heightFactor; // tinggi lapisan (1.0, 1.2)

  const FloatCfg({
    required this.dur,
    required this.ax,
    required this.ay,
    required this.ph,
    required this.o,
    required this.heightFactor,
  });
}

class LoginEffectCfg {
  static const int durationMs = 1400; // lama transisi (ms)
  static const double bgBack = 0.6; // jarak latar belakang naik
  static const double bgFront = 1.2; // jarak latar depan naik
  static const double drop = 1.1; // jarak partikel turun

  // Gambar aset sesuai petunjuk
  static const imgBg = 'assets/backgorund1.png'; // gambar 1 = latar belakang
  static const imgFloat = 'assets/backgorund3.png'; // gambar 2 = partikel mengambang

  // Dua lapisan partikel
  static const floats = [
    FloatCfg(dur: 4200, ax: 5, ay: 12, ph: 0.0, o: 0.55, heightFactor: 1.0),
    FloatCfg(dur: 3000, ax: 4, ay: 10, ph: 0.5, o: 1.0, heightFactor: 1.2),
  ];

  // Warna
  static const ink = Color(0xFF0B2A6B);
  static const sub = Color(0xFF3A5AA8);
  static const accent = Color(0xFF1F6BFF);
  static const stage = Color(0xFFE8EEFB);
  static const cardBg = Color(0xFFF4F7FF);
}

/* =====================================================================
   2. FUNGSI BANTU MATEMATIKA
   ===================================================================== */

/// Easing sinus untuk gerak mengambang: ease(t)
double _ease(double t) => -(math.cos(math.pi * t) - 1) / 2;

/// Bolak-balik 0 -> 1 -> 0 seiring waktu
double _pingpong(double ms, double d, double ph) {
  final p = ((ms / d) + ph) % 2;
  return p < 1 ? p : 2 - p;
}

/// Easing cubic untuk transisi login: pelan -> cepat -> pelan
double _cubicInOut(double t) {
  return t < 0.5
      ? 4 * t * t * t
      : 1.0 - math.pow(-2 * t + 2, 3) / 2.0;
}

/// Batasi nilai ke rentang 0..1
double _clamp(double v) => v.clamp(0.0, 1.0);

/* =====================================================================
   3. HALAMAN LOGIN DENGAN ADAPTASI EFEK TWEEN FLOAT + TRANSISI NAIK
   ===================================================================== */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final Ticker _ticker;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  double _s = 0.0; // progres transisi (0..1)
  double _target = 0.0; // tujuan: 0 = login, 1 = sudah masuk
  double _ms = 0.0; // waktu berjalan (ms)
  double _lastTime = 0.0;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String _errorMessage = '';
  String _loggedInUserName = '';

  @override
  void initState() {
    super.initState();

    // Ticker untuk loop animasi (+-60fps)
    _ticker = createTicker((elapsed) {
      final now = elapsed.inMicroseconds / 1000.0;
      final dt = _lastTime == 0.0 ? 16.0 : (now - _lastTime);
      _lastTime = now;
      _ms = now;

      // Gerakkan _s menuju _target seiring waktu sesuai durationMs
      if (_s < _target) {
        _s = math.min(_target, _s + dt / LoginEffectCfg.durationMs);
      } else if (_s > _target) {
        _s = math.max(_target, _s - dt / LoginEffectCfg.durationMs);
      }

      _frame.value++;
    })..start();

    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedEmail() async {
    final rememberMe = await SecureStorage.read('remember_me');
    if (rememberMe == 'true') {
      final savedEmail = await SecureStorage.read('saved_email');
      if (savedEmail != null && savedEmail.isNotEmpty && mounted) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final user = result['user'];
      final int role = int.tryParse(user['id_tipeuser'].toString()) ?? 0;
      final userName = user['nama']?.toString() ?? 'Pengguna';

      if (_rememberMe) {
        await SecureStorage.write('saved_email', _emailController.text.trim());
        await SecureStorage.write('remember_me', 'true');
      } else {
        await SecureStorage.delete('saved_email');
        await SecureStorage.delete('remember_me');
      }

      setState(() {
        _loggedInUserName = userName;
        _target = 1.0; // <-- PEMICU TRANSISI NAIK!
      });

      // Tunggu hingga transisi selesai penuh
      await Future.delayed(
        const Duration(milliseconds: LoginEffectCfg.durationMs + 200),
      );

      if (!mounted) return;

      Widget destinationPage;
      if (role == 1) {
        destinationPage = const AdminShell();
      } else if (role == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login Guru berhasil. Halaman Guru belum dihubungkan.',
            ),
          ),
        );
        setState(() => _target = 0.0);
        return;
      } else if (role == 3) {
        destinationPage = const DashboardScreen();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role pengguna tidak dikenali.')),
        );
        setState(() => _target = 0.0);
        return;
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => destinationPage,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _target = 0.0;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Gambar piksel tajam tanpa blur
  Widget _pixelImage(
    String path, {
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
  }) {
    return Image.asset(
      path,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.none,
      width: double.infinity,
      height: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginEffectCfg.stage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double w = constraints.maxWidth;
              final double h = constraints.maxHeight;

              return ClipRect(
                child: AnimatedBuilder(
                  animation: _frame,
                  builder: (context, _) {
                    final double p = _cubicInOut(_s);

                    return Stack(
                      children: [
                        // ===============================================
                        // 1. LAPISAN EFEK (Di belakang konten)
                        // ===============================================

                        // (a) Latar Belakang Lapisan 1 (naik pelan)
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(0, -p * h * LoginEffectCfg.bgBack),
                            child: _pixelImage(
                              LoginEffectCfg.imgBg,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // (b) Latar Belakang Lapisan 2 (naik cepat, cermin, transparan)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.55,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.translationValues(
                                0,
                                -p * h * LoginEffectCfg.bgFront,
                                0,
                              )..scaleByDouble(-1.2, 1.2, 1.0, 1.0),
                              child: _pixelImage(
                                LoginEffectCfg.imgBg,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // (c) Dua Lapisan Partikel Mengambang (turun + memudar)
                        ..._buildFloats(w, h, p),

                        // ===============================================
                        // 2. LAYAR LOGIN (Terangkat ke atas & memudar saat transisi)
                        // ===============================================
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(0, -p * h * 0.8),
                            child: Opacity(
                              opacity: _clamp(1.0 - p * 1.6),
                              child: IgnorePointer(
                                ignoring: _s > 0.05,
                                child: _buildLoginForm(context, w, h),
                              ),
                            ),
                          ),
                        ),

                        // ===============================================
                        // 3. HALAMAN SETELAH LOGIN (Naik dari bawah menutupi layar)
                        // ===============================================
                        ..._buildHomeTransitionSheet(w, h, p),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Membangun partikel mengambang
  List<Widget> _buildFloats(double w, double h, double p) {
    final double fade = _clamp(1.0 - p * 1.4);

    return LoginEffectCfg.floats.map((l) {
      final double layerW = w * 1.12;
      final double layerH = h * l.heightFactor;

      final double ex =
          _ease(_pingpong(_ms, l.dur * 1.3, l.ph)) * 2.0 - 1.0;
      final double ey =
          _ease(_pingpong(_ms, l.dur.toDouble(), 0)) * 2.0 - 1.0;

      final double floatX = ex * l.ax / 100.0 * layerW;
      final double floatY = -ey * l.ay / 100.0 * layerH;
      final double dropY = p * h * LoginEffectCfg.drop;

      return Positioned(
        left: w * (-0.06),
        width: layerW,
        height: layerH,
        bottom: h * (-0.14),
        child: Transform.translate(
          offset: Offset(floatX, floatY + dropY),
          child: Opacity(
            opacity: (l.o * fade).clamp(0.0, 1.0),
            child: _pixelImage(
              LoginEffectCfg.imgFloat,
              fit: BoxFit.fill,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Membangun Form Login Asli Arrava
  Widget _buildLoginForm(BuildContext context, double w, double h) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Logo & Header
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LoginEffectCfg.accent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: LoginEffectCfg.accent.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_outlined,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Arrava Mobile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: LoginEffectCfg.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          const Text(
            'Silakan login untuk melanjutkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: LoginEffectCfg.sub,
            ),
          ),

          const SizedBox(height: 28),

          // Card Login Form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFC9D7F5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A2878).withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Label Username
                  const Text(
                    'Username atau Email',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: LoginEffectCfg.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    validator: (val) =>
                        (val == null || val.trim().isEmpty)
                            ? 'Username atau email wajib diisi'
                            : null,
                    decoration: InputDecoration(
                      hintText: 'admin / username',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.alternate_email,
                        size: 20,
                        color: LoginEffectCfg.sub,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFC9D7F5),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFC9D7F5),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: LoginEffectCfg.accent,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Label Password
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: LoginEffectCfg.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) =>
                        (val == null || val.trim().isEmpty)
                            ? 'Kata sandi wajib diisi'
                            : null,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: LoginEffectCfg.sub,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFC9D7F5),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFC9D7F5),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: LoginEffectCfg.accent,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Ingat Saya & Lupa Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() => _rememberMe = val ?? false);
                              },
                              activeColor: LoginEffectCfg.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Ingat saya',
                            style: TextStyle(
                              fontSize: 13,
                              color: LoginEffectCfg.sub,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: LoginEffectCfg.accent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC0262D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Tombol Masuk
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LoginEffectCfg.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Membangun Halaman Setelah Login (Sheet yang naik dari bawah menutupi layar)
  List<Widget> _buildHomeTransitionSheet(double w, double h, double p) {
    final double q = _clamp((p - 0.2) / 0.8);
    if (q <= 0.0) return [];

    final double sheetTop = (1.0 - q) * h;

    return [
      Positioned(
        left: 0,
        right: 0,
        top: sheetTop,
        height: h,
        child: Container(
          width: w,
          height: h,
          padding: EdgeInsets.fromLTRB(
            22,
            14,
            22,
            40 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF4F7FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x330A2878),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9C8EE),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              const Spacer(),

              // Success Icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: LoginEffectCfg.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: LoginEffectCfg.accent,
                      size: 42,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Halo, $_loggedInUserName!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: LoginEffectCfg.ink,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              const Center(
                child: Text(
                  'Login berhasil. Mengarahkan ke Beranda...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: LoginEffectCfg.sub,
                  ),
                ),
              ),

              const Spacer(),

              // Progress indicator transisi
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: q,
                  backgroundColor: const Color(0xFFD6E0F7),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    LoginEffectCfg.accent,
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ];
  }
}
