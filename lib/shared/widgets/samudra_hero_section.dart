import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../providers/notification_provider.dart';

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

  String _formatNumber(int n) {
    final s = n.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        // Tinggi card samudra proporsional yang memuat Profil, Kartu EXP Glassmorphic & Sapaan Aksi
        final cardH = cardW < 500 ? 325.0 : (cardW < 800 ? 295.0 : 270.0);

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
            child: _buildOverlaidContent(),
          ),
        ],
      ),
    );
  }

  /// Konten Profil Siswa, Kartu Peringkat & EXP, dan Quick Action Shortcuts yang menimpa samudra
  Widget _buildOverlaidContent() {
    final user = widget.user;
    final stats = widget.stats;

    // Ekstraksi data rank_tier / stats
    final rankInfo = (user?['rank_tier'] as Map<String, dynamic>?) ??
        (user?['rank'] as Map<String, dynamic>?) ??
        <String, dynamic>{};

    final currentRank = rankInfo['current_rank']?.toString() ?? 'Pemula';
    final currentBadgeUrl = rankInfo['current_badge_url']?.toString();
    final nextRank = rankInfo['next_rank']?.toString() ?? 'Lanjutan';
    final currentPoints = (rankInfo['current_points'] as num?)?.toInt() ??
        (user?['total_xp'] as num?)?.toInt() ??
        (stats?['total_xp'] as num?)?.toInt() ??
        0;
    final nextPoints = (rankInfo['next_points'] as num?)?.toInt() ?? 100;
    final pointsNeeded = (rankInfo['points_needed'] as num?)?.toInt() ??
        (nextPoints > currentPoints ? nextPoints - currentPoints : 0);
    final percent = ((rankInfo['percent'] as num?)?.toInt() ??
            (stats?['progress_percent'] as num?)?.toInt() ??
            0)
        .clamp(0, 100);
    final isMax = rankInfo['is_max'] == true;

    final kuisLulus = stats?['kuis_lulus'] ?? 0;
    final modulCount = widget.modulCount > 0
        ? widget.modulCount
        : (stats?['kursus_aktif'] ?? 0);
    final jenjangName = user?['jenjang']?.toString() ?? 'SD';
    final studentName = user?['nama']?.toString() ?? 'Siswa Arrava';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 390;
          final isVeryCompact = constraints.maxWidth < 340;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bagian 1: Profil Siswa & Level
              _buildTopProfileRow(
                isCompact: isCompact,
                isVeryCompact: isVeryCompact,
                studentName: studentName,
                jenjangName: jenjangName,
                currentRank: currentRank,
                kuisLulus: kuisLulus,
                modulCount: modulCount,
                user: user,
              ),

              // Bagian 2: Peleburan Kartu Peringkat & EXP (Glassmorphic persis Web)
              _buildRankExpCard(
                isCompact: isCompact,
                currentRank: currentRank,
                currentBadgeUrl: currentBadgeUrl,
                currentPoints: currentPoints,
                nextRank: nextRank,
                nextPoints: nextPoints,
                pointsNeeded: pointsNeeded,
                percent: percent,
                isMax: isMax,
              ),

              // Bagian 3: Sapaan Hangat & Quick Actions (Mulai Belajar & Latihan Kuis)
              _buildBottomActionRow(
                isCompact: isCompact,
                studentName: studentName,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Baris Atas: Foto Profil Siswa, Nama, Badge Jenjang, Level & Notifikasi
  Widget _buildTopProfileRow({
    required bool isCompact,
    required bool isVeryCompact,
    required String studentName,
    required String jenjangName,
    required String currentRank,
    required dynamic kuisLulus,
    required dynamic modulCount,
    required Map<String, dynamic>? user,
  }) {
    final avatarRadius = isCompact ? 20.0 : 23.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar Siswa dengan gradient ring
        GestureDetector(
          onTap: widget.onProfileTap,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Builder(
                builder: (context) {
                  final rawPhoto = (user?['foto_profil'] ??
                          user?['foto_profil_url'] ??
                          user?['foto'])
                      ?.toString();
                  final resolvedPhoto = ApiConstants.resolveMediaUrl(rawPhoto);
                  if (resolvedPhoto != null && resolvedPhoto.isNotEmpty) {
                    return Image.network(
                      resolvedPhoto,
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, _) {
                        debugPrint(
                          '[HERO AVATAR ERROR] Failed loading: $resolvedPhoto | Error: $error',
                        );
                        return _buildAvatarFallback(studentName, avatarRadius);
                      },
                    );
                  }
                  return _buildAvatarFallback(studentName, avatarRadius);
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Info Siswa: Nama, Badge Jenjang, & Level Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isCompact ? 13.5 : 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6EE7B7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 9.5,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 2.5),
                        Text(
                          jenjangName,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2.5),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Level: $currentRank',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '• $kuisLulus Kuis',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  if (!isVeryCompact)
                    Text(
                      '• $modulCount Modul',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.95),
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Tombol Notifikasi Presensi
        if (widget.onNotificationTap != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: widget.onNotificationTap,
            child: Consumer<NotificationProvider>(
              builder: (context, notifProvider, _) {
                final unread = notifProvider.unreadCount;
                return Container(
                  padding: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        size: 17,
                        color: Color(0xFF12233F),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarFallback(String name, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF007FBE), Color(0xFF51CDF4)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Bagian 2: Kartu Glassmorphic Peringkat & EXP (Peleburan persis Elearning Web)
  Widget _buildRankExpCard({
    required bool isCompact,
    required String currentRank,
    required String? currentBadgeUrl,
    required int currentPoints,
    required String nextRank,
    required int nextPoints,
    required int pointsNeeded,
    required int percent,
    required bool isMax,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 7 : 8.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris 1: Label PERINGKAT & EXP + Pill Tombol Leaderboard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERINGKAT & EXP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              GestureDetector(
                onTap: widget.onLeaderboardTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
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
                      if (currentBadgeUrl != null &&
                          currentBadgeUrl.isNotEmpty)
                        Image.network(
                          currentBadgeUrl,
                          width: 13,
                          height: 13,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Text(
                            '★',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 11,
                            ),
                          ),
                        )
                      else
                        const Text(
                          '★',
                          style: TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(width: 3),
                      Text(
                        currentRank,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Baris 2: EXP Points Besar + Target Rank
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatNumber(currentPoints),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isCompact ? 20 : 23,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'EXP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFDE047),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: isMax
                    ? const Text(
                        'Tingkat Tertinggi 👑',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6EE7B7),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              children: [
                                const TextSpan(text: 'Menuju '),
                                TextSpan(
                                  text: nextRank,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_formatNumber(currentPoints)} / ${_formatNumber(nextPoints)}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Baris 3: Icon EXP widget + Animated Progress Bar + Persentase
          Row(
            children: [
              Image.asset(
                'assets/widget/exp.png',
                width: 17,
                height: 17,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 8.5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (percent / 100).clamp(0.02, 1.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFBBF24),
                              Color(0xFFFB923C),
                              Color(0xFFF59E0B),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 32,
                child: Text(
                  '$percent%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFDE047),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5.5),

          // Baris 4: Footer Sisa EXP & Link Leaderboard
          Container(
            padding: const EdgeInsets.only(top: 4.5),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: isMax
                      ? const Text(
                          'Hebat! Semua tingkat terbuka.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6EE7B7),
                          ),
                        )
                      : RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                            children: [
                              const TextSpan(text: 'Sisa '),
                              TextSpan(
                                text: '${_formatNumber(pointsNeeded)} EXP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(text: ' lagi'),
                            ],
                          ),
                        ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onLeaderboardTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat leaderboard',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFDE047),
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '→',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFDE047),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bagian 3: Sapaan Hangat Siswa & Quick Action Shortcuts
  Widget _buildBottomActionRow({
    required bool isCompact,
    required String studentName,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Halo, $studentName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isCompact ? 12.5 : 13.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Jelajahi materi & raih ranking teratas!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.90),
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Tombol Mulai Belajar (Glass White Pill)
          GestureDetector(
            onTap: widget.onExploreTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 12,
                    color: Color(0xFF007FBE),
                  ),
                  SizedBox(width: 3.5),
                  Text(
                    'Belajar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF007FBE),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Tombol Latihan Kuis (3D Blue Pill)
          GestureDetector(
            onTap: widget.onQuizTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF007FBE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00628E)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF00628E),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 3.5),
                  Text(
                    'Kuis',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
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
