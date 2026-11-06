import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _navy = Color(0xFF06203F);
const Color _foam = Color(0xFFE9FBFF);
const Color _sand = Color(0xFFFFD36B);

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
  final VoidCallback? onExploreTap;
  final VoidCallback? onProfileTap;

  const SamudraHeroSection({
    super.key,
    this.user,
    this.stats,
    this.onExploreTap,
    this.onProfileTap,
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
  bool _paused = false;
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

  // Area renang di bagian bawah perairan agar leluasa dan tidak menutupi search bar
  Rect _bounds(Fish f) {
    final w = _size.width, h = _size.height;
    return Rect.fromLTRB(
      -f.size * 0.1,
      math.max(115.0, h * 0.44),
      math.max(100.0, w - f.size * 0.85),
      math.max(h * 0.6, h - f.size * 0.65),
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
        // Tinggi card samudra yang lebih pendek dan ringkas
        final cardH = cardW < 500 ? 250.0 : (cardW < 800 ? 275.0 : 305.0);

        final size = Size(cardW, cardH);
        _syncLayout(size);

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(6, 32, 63, .16),
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

          // 2. Efek Overlay Gradasi Cahaya
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, .35],
                    colors: const [
                      Color.fromRGBO(255, 255, 255, .18),
                      Color.fromRGBO(255, 255, 255, 0),
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

          // 5. Konten Menimpa: Profil, Bar EXP, & Pencarian Materi
          Positioned(left: 0, right: 0, top: 0, child: _buildOverlaidContent()),
        ],
      ),
    );
  }

  /// Konten Profil, Bar EXP & Search Bar yang menimpa samudra
  Widget _buildOverlaidContent() {
    final user = widget.user;
    final stats = widget.stats;
    final level = stats?['level'] ?? 1;
    final totalXp = user?['total_xp'] ?? stats?['total_xp'] ?? 0;
    final kuisLulus = stats?['kuis_lulus'] ?? 0;
    final progressPercent =
        (stats?['progress_percent'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Baris Atas: Foto Profil di kiri, Bar EXP di kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto Profil Siswa
              GestureDetector(
                onTap: widget.onProfileTap,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFF97316),
                    backgroundImage:
                        (user?['foto_profil'] != null &&
                            user!['foto_profil'].toString().isNotEmpty)
                        ? NetworkImage(user['foto_profil'] as String)
                        : null,
                    child:
                        (user?['foto_profil'] == null ||
                            user!['foto_profil'].toString().isEmpty)
                        ? const Icon(
                            Icons.sentiment_very_satisfied_rounded,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                ),
              ),

              // Bar EXP Pill: Menggantikan Bar Santai dengan Bar EXP
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalXp EXP',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Progress bar mini bersegmen 5 segmen
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final int filledSegments = ((progressPercent / 100) * 5)
                            .round()
                            .clamp(1, 5);
                        final bool isFilled = index < filledSegments;
                        return Container(
                          width: 10,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFEE2E2),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        size: 12,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2. Baris Tengah: Nama Siswa & Jenjang Badge (Tanpa persentase & pesan)
          Row(
            children: [
              Flexible(
                child: Text(
                  user != null && user['nama'] != null
                      ? user['nama'].toString()
                      : 'Siswa Arrava',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 11,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      user?['jenjang'] != null ? '${user!['jenjang']}' : 'SD',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 1),

          // Sub-info: Level & Kuis
          Text(
            'Level $level • $kuisLulus Kuis Selesai',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
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
