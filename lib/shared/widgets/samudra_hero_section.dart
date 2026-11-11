import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hero_dashboard_overlay.dart';

final _rng = math.Random();
double _rand(double a, double b) => a + _rng.nextDouble() * (b - a);

// Easing untuk tween
double _easeSine(double t) => -(math.cos(math.pi * t) - 1) / 2;
double _easeOut(double t) => 1 - math.pow(1 - t, 3).toDouble();

/// Data satu ikan: posisi, tujuan tween, dan state animasinya.
class Fish {
  Fish({required this.asset, required this.size, required this.speed});

  final String asset;
  double size;
  double speed; // px per detik (bisa diupdate saat layout / hot reload)

  double x = 0, y = 0; // posisi sekarang
  double sx = 0, sy = 0, tx = 0, ty = 0; // awal & tujuan tween
  double t0 = 0, dur = 1;
  double Function(double) ease = _easeSine;
  bool resting = true;
  double restUntil = 0;
  bool isOffScreen = false; // status apakah ikan sedang di luar batas layar

  double face = 1; // arah hadap: 1 kanan, -1 kiri
  double flip = 1; // nilai scaleX yang dihaluskan (berbalik arah)
  double phase = _rand(0, 6); // fase goyang ekor
  double seed = _rand(0, 9);
  double tilt = 0; // kemiringan (derajat)
  double sp = 0; // kecepatan sesaat
  double flee = -10; // waktu terakhir kabur dari kursor
}

/// Hero Section Samudra Piksel interaktif untuk Dashboard Arrava Mobile
class SamudraHeroSection extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? stats;
  final int modulCount;
  final int quizCount;
  final VoidCallback? onExploreTap;
  final VoidCallback? onQuizTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLeaderboardTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onToggleHeroTheme;
  final bool isHeroSwitching;

  const SamudraHeroSection({
    super.key,
    this.user,
    this.stats,
    this.modulCount = 0,
    this.quizCount = 0,
    this.onExploreTap,
    this.onQuizTap,
    this.onProfileTap,
    this.onLeaderboardTap,
    this.onNotificationTap,
    this.onToggleHeroTheme,
    this.isHeroSwitching = false,
  });

  @override
  State<SamudraHeroSection> createState() => _SamudraHeroSectionState();
}

class _SamudraHeroSectionState extends State<SamudraHeroSection>
    with SingleTickerProviderStateMixin {
  static const _assets = [
    'assets/widget/cards/fish1.webp',
    'assets/widget/cards/fish2.webp',
    'assets/widget/cards/fish3.webp',
    'assets/widget/cards/fish4.webp',
    'assets/widget/cards/fish5.webp',
    'assets/widget/cards/fish6.webp',
    'assets/widget/cards/fish7.webp',
    'assets/widget/cards/fish8.webp',
    'assets/widget/cards/fish9.webp',
  ];
  static const _ks = [
    23.0, // Ikan 1 (Sedang: ~115px)
    22.0, // Ikan 2 (Lincah & Ramping: ~95px)
    33.0, // Ikan 3 (Paling Besar & Gagah: ~145px)
    22.0, // Ikan 4 (Lincah: ~100px)
    22.0, // Ikan 5 (Sedang-Besar: ~120px)
    32.0,
    35.0,
    37.0,
    22.0,
  ]; // Ukuran pixel visual nyata langsung (dp) yang jelas dan proporsional di layar
  static const _speeds = [
    12.0,
    16.0,
    9.0,
    15.0,
    11.0,
    11.5,
    12.0,
    12.5,
    13.0,
  ]; // Kecepatan renang santai & tenang (px per detik)

  late final Ticker _ticker;
  final _tick = ValueNotifier<int>(0);
  Duration _lastElapsed = Duration.zero;
  double _t = 0; // waktu animasi (berhenti saat dijeda)
  final bool _paused = false;
  Size _size = Size.zero;
  final List<Fish> _fish = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tick.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1e6)
        .clamp(0.001, 0.05)
        .toDouble();
    _lastElapsed = elapsed;
    if (_fish.isEmpty || _paused) return;
    _step(dt);
    _tick.value++;
  }

  // Area renang di bagian perairan agar leluasa, aman dari tepian melengkung dan tidak terpotong
  Rect _bounds(Fish f) {
    final w = _size.width, h = _size.height;
    return Rect.fromLTRB(
      14.0,
      math.max(66.0, h * 0.30),
      math.max(100.0, w - f.size - 18.0),
      math.max(h * 0.55, h - f.size - 18.0),
    );
  }

  // Ukuran ikan dalam pixel nyata langsung dari _ks (dapat diubah-ubah bebas)
  double _sizeFor(int i, double w) {
    final scale = (w / 380.0).clamp(0.95, 1.4);
    return _ks[i] * scale;
  }

  void _syncLayout(Size size) {
    _size = size;
    if (_fish.isEmpty) {
      for (var i = 0; i < _assets.length; i++) {
        final f = Fish(
          asset: _assets[i],
          size: _sizeFor(i, size.width),
          speed: _speeds[i],
        );
        final b = _bounds(f);
        f
          ..x = _rand(b.left, b.right)
          ..y = _rand(b.top, b.bottom)
          ..face = _rng.nextBool() ? 1.0 : -1.0
          ..restUntil = _rand(.1, 1.2);
        f.flip = f.face;
        _fish.add(f);
      }
    } else {
      // Selalu perbarui ukuran dan kecepatan setiap layout (Hot Reload Friendly!)
      for (var i = 0; i < _fish.length; i++) {
        _fish[i].size = _sizeFor(i, size.width);
        _fish[i].speed = _speeds[i];
      }
    }
  }

  void _go(
    Fish f,
    double tx,
    double ty,
    double dur,
    double Function(double) ease,
  ) {
    f
      ..sx = f.x
      ..sy = f.y
      ..tx = tx
      ..ty = ty
      ..t0 = _t
      ..dur = dur
      ..ease = ease
      ..resting = false;
    if ((tx - f.x).abs() > 8) f.face = tx > f.x ? 1.0 : -1.0;
  }

  void _pick(Fish f) {
    final b = _bounds(f);
    final w = _size.width;

    // 1. Jika ikan sedang berada di luar layar, arahkan untuk berenang masuk kembali
    if (f.isOffScreen) {
      final enterFromLeft = _rng.nextBool();
      final double startX = enterFromLeft ? (-f.size - 30.0) : (w + 30.0);
      final double startY = _rand(b.top, b.bottom);

      f.x = startX;
      f.y = startY;
      f.face = enterFromLeft ? 1.0 : -1.0;
      f.flip = f.face;
      f.isOffScreen = false;

      // Target masuk kembali ke area berenang di dalam layar
      final double targetX = enterFromLeft
          ? _rand(b.left + 40.0, math.min(w * 0.65, b.right))
          : _rand(math.max(w * 0.35, b.left), b.right - 40.0);
      final double targetY = _rand(b.top, b.bottom);
      final d = math.sqrt(
        (targetX - f.x) * (targetX - f.x) + (targetY - f.y) * (targetY - f.y),
      );
      final double dur = (d / f.speed).clamp(10.0, 26.0);
      _go(f, targetX, targetY, dur, _easeSine);
      return;
    }

    // 2. Ikan yang sedang di layar punya peluang (35%) untuk berenang keluar layar!
    final bool exitScreen = _rng.nextDouble() < 0.35;
    if (exitScreen) {
      // Keluar ke kanan atau ke kiri sesuai arah hadap atau posisi terdekat
      final bool exitRight = f.face > 0 || (f.x > w * 0.5);
      final double targetX = exitRight ? (w + f.size + 40.0) : (-f.size - 40.0);
      final double targetY = (f.y + _rand(-25, 25)).clamp(b.top, b.bottom);

      final d = math.sqrt(
        (targetX - f.x) * (targetX - f.x) + (targetY - f.y) * (targetY - f.y),
      );
      final double dur = (d / f.speed).clamp(10.0, 26.0);
      _go(f, targetX, targetY, dur, _easeSine);
      return;
    }

    // 3. Gerakan acak normal di dalam layar (sangat tenang dan anggun)
    double tx;
    var n = 0;
    do {
      tx = _rand(b.left, b.right);
    } while ((tx - f.x).abs() < w * .15 && ++n < 8);
    final ty = _rand(b.top, b.bottom);
    final d = math.sqrt((tx - f.x) * (tx - f.x) + (ty - f.y) * (ty - f.y));
    final double dur = (d / f.speed).clamp(8.0, 22.0);
    _go(f, tx, ty, dur, _easeSine);
  }

  // Ikan kabur cepat dari kursor (hover) atau sentuhan langsung dengan tween easeOut
  void _scare(Offset p, double power) {
    for (final f in _fish) {
      if (f.isOffScreen) continue;
      final cx = f.x + f.size / 2, cy = f.y + f.size / 2;
      final dx = cx - p.dx, dy = cy - p.dy;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d > power || _t - f.flee < 0.7) continue;
      final ux = dx / (d == 0 ? 1 : d), uy = dy / (d == 0 ? 1 : d);
      final dist = _rand(130.0, 220.0);
      final b = _bounds(f);
      final targetX = (f.x + ux * dist).clamp(b.left, b.right);
      final targetY = (f.y + uy * dist * 0.6).clamp(b.top, b.bottom);
      _go(f, targetX, targetY, 1.1, _easeOut);
      f.flee = _t;
    }
  }

  void _step(double dt) {
    _t += dt;
    for (final f in _fish) {
      final px = f.x, py = f.y;
      if (f.resting) {
        if (_t >= f.restUntil) _pick(f);
      } else {
        final p = ((_t - f.t0) / f.dur).clamp(0.0, 1.0).toDouble();
        final e = f.ease(p);
        f.x = f.sx + (f.tx - f.sx) * e;
        f.y = f.sy + (f.ty - f.sy) * e;
        if (p >= 1) {
          f.resting = true;
          // Cek apakah sekarang sudah di luar batas layar
          if (f.x < -f.size || f.x > _size.width) {
            f.isOffScreen = true;
            f.restUntil = _t + _rand(3.0, 6.0);
          } else {
            f.restUntil = _t + _rand(2.0, 5.0);
          }
        }
      }
      final vx = (f.x - px) / dt, vy = (f.y - py) / dt;
      f.sp = math.sqrt(vx * vx + vy * vy);
      // Ekor berayun santai saat renang normal, dan mengibas cepat saat kaget kabur
      final tailSpeed = 1.5 + math.min(f.sp / 80.0, 1.0) * 4.5;
      f.phase += dt * tailSpeed;
      f.flip += (f.face - f.flip) * math.min(1.0, dt * 4.0);
      final target = (vy * .03).clamp(-8.0, 8.0).toDouble() * f.face;
      f.tilt += (target - f.tilt) * math.min(1.0, dt * 3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        // Tinggi card samudra proporsional yang memuat Profil, Kartu EXP Glassmorphic & Sapaan Aksi
        final cardH = cardW < 500 ? 330.0 : (cardW < 800 ? 295.0 : 275.0);

        final size = Size(cardW, cardH);
        _syncLayout(size);

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: const Color(0xFF0C4A6E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDCEFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(6, 32, 63, .18),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _heroCard(size),
          ),
        );
      },
    );
  }

  /// Isi card: background, ikan, gelembung.
  Widget _heroCard(Size size) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerHover: (e) => _scare(e.localPosition, 110),
      onPointerDown: (e) => _scare(e.localPosition, 180),
      child: Stack(
        children: [
          // 1. Gambar Latar Belakang Bawah Laut
          Positioned.fill(
            child: Image.asset(
              'assets/widget/cards/underwaterHeroSection.webp',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.none,
            ),
          ),

          // 2. Efek Overlay Gradasi Cahaya Atas
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, .40],
                    colors: [
                      Colors.white.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Ikan-ikan Berenang Bebas
          Positioned.fill(
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _tick,
                  builder: (context, _) =>
                      Stack(children: [for (final f in _fish) _fishWidget(f)]),
                ),
              ),
            ),
          ),

          // 4. Gelembung Udara Naik
          Positioned.fill(
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _tick,
                  builder: (context, _) => Stack(
                    children: [for (var k = 0; k < 14; k++) _bubble(k, size)],
                  ),
                ),
              ),
            ),
          ),

          // 5. Konten Menimpa: Profil Siswa, Kartu Peringkat & EXP, serta Sapaan Hangat & Quick Actions
          Positioned.fill(
            child: HeroDashboardOverlay(
              user: widget.user,
              stats: widget.stats,
              modulCount: widget.modulCount,
              quizCount: widget.quizCount,
              heroTheme: 'samudra',
              onExploreTap: widget.onExploreTap,
              onQuizTap: widget.onQuizTap,
              onProfileTap: widget.onProfileTap,
              onLeaderboardTap: widget.onLeaderboardTap,
              onNotificationTap: widget.onNotificationTap,
              onToggleHeroTheme: widget.onToggleHeroTheme,
              isHeroSwitching: widget.isHeroSwitching,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fishWidget(Fish f) {
    final bob = math.sin(_t * 1.2 + f.seed) * 3;
    final amp = 4.0 + math.min(f.sp / 60.0, 1.0) * 6.0;
    final wig = math.sin(f.phase) * amp * math.pi / 180;
    final squash = 1 + math.sin(f.phase + 1.2) * .03;
    return Positioned(
      left: f.x,
      top: f.y + bob,
      child: Transform.rotate(
        angle: f.tilt * math.pi / 180,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(f.flip, squash, 1.0)..rotateZ(wig),
          child: SizedBox(
            width: f.size,
            height: f.size,
            child: Image.asset(
              f.asset,
              fit: BoxFit.contain, // Memperbesar sprite 16px menjadi ukuran f.size sebenarnya!
              filterQuality:
                  FilterQuality.none, // Pixel art tetap tajam, renyah & retro
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(int k, Size s) {
    final period = 9 + (k * 1.7) % 8;
    final offset = (k * 2.3) % 12;
    final p = ((_t + offset) / period) % 1.0;
    final b = [6.0, 8.0, 10.0, 12.0][k % 4];
    final x =
        ((k * 6.3 + 3) % 98) / 100 * s.width + math.sin(p * math.pi * 4) * 8;
    final y = s.height + 20 - p * s.height * 1.12;
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: (1 - p * .9).clamp(.1, 1.0).toDouble(),
        child: Container(
          width: b,
          height: b,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(233, 251, 255, .18),
            border: Border.all(
              color: const Color.fromRGBO(233, 251, 255, .75),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol bergaya pixel dengan bayangan keras.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.bg,
    required this.fg,
    required this.shadow,
    this.small = false,
  });

  final String label;
  final VoidCallback onTap;
  final Color bg, fg, shadow;
  final bool small;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final off = _hover ? 2.0 : 0.0;
    final sh = (widget.small ? 3.0 : 4.0) - off;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(off, off, 0),
          padding: EdgeInsets.symmetric(
            horizontal: widget.small ? 14 : 22,
            vertical: widget.small ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.shadow,
                offset: Offset(sh, sh),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.pixelifySans(
              fontSize: widget.small ? 13 : 16,
              fontWeight: FontWeight.w700,
              color: widget.fg,
            ),
          ),
        ),
      ),
    );
  }
}
