import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'hero_dashboard_overlay.dart';

final _galaxyRng = math.Random();
double _galaxyRand(double a, double b) =>
    a + _galaxyRng.nextDouble() * (b - a);

class _Asteroid {
  _Asteroid({
    required this.asset,
    required this.baseW,
    required this.baseH,
    required this.mass,
  });

  final String asset;
  final double baseW;
  final double baseH;
  final double mass;

  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double angle = 0;
  double angVel = 0;
  double w = 24;
  double h = 20;
  double r = 12;
  bool dragging = false;
}

/// Hero Section Galaksi Piksel interaktif untuk Dashboard Arrava Mobile.
/// Menampilkan ruang angkasa berpiksel, bintang berkedip 4-frame, cincin planet,
/// bulan mengorbit, serta 9 asteroid fisika yang bisa disentuh, diseret, dan dilempar.
class GalaksiHeroSection extends StatefulWidget {
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

  const GalaksiHeroSection({
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
  State<GalaksiHeroSection> createState() => _GalaksiHeroSectionState();
}

class _GalaksiHeroSectionState extends State<GalaksiHeroSection>
    with SingleTickerProviderStateMixin {
  static const _basePath = 'assets/widget/cards/herosection/herosection2';
  static const _rockMults = [1.0, 1.0, 0.75, 1.25, 1.0, 0.75, 1.25, 1.0, 0.75];

  late final Ticker _ticker;
  late final List<_Asteroid> _rocks;
  final ValueNotifier<int> _tick = ValueNotifier<int>(0);

  Size _size = Size.zero;
  double _t = 0;
  double _last = 0;

  // Planet utama melayang pelan di belahan kanan ruang angkasa
  double _planetX = 0;
  double _planetY = 0;
  double _planetVx = 8;
  double _planetVy = 5;

  @override
  void initState() {
    super.initState();
    _rocks = List.generate(_rockMults.length, (i) {
      final isFirst = i.isEven;
      final mult = _rockMults[i];
      return _Asteroid(
        asset: '$_basePath/${isFirst ? 'asteroid-1.webp' : 'asteroid-2.webp'}',
        baseW: (isFirst ? 32.0 : 21.0) * mult,
        baseH: (isFirst ? 27.0 : 17.0) * mult,
        mass: mult * mult,
      );
    });

    _ticker = createTicker((elapsed) {
      final now = elapsed.inMicroseconds / 1e6;
      if (_last == 0) {
        _last = now;
        return;
      }
      final dt = math.min(0.05, math.max(0.001, now - _last));
      _last = now;
      if (_size != Size.zero) {
        _step(dt);
        _tick.value++;
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tick.dispose();
    super.dispose();
  }

  double _propScale(double w, double h) {
    final wCap = w < 700
        ? 2.0
        : (w > 1400 ? 5.0 : (w > 1000 ? 4.0 : 3.0));
    return math.min(wCap, math.max(1.85, h / 115.0));
  }

  void _syncLayout(Size s) {
    if ((s.width - _size.width).abs() < 1 &&
        (s.height - _size.height).abs() < 1) {
      return;
    }

    final firstInit = _size == Size.zero;
    _size = s;

    final k = _propScale(s.width, s.height);
    final rockScale = (s.width < 500 ? 0.56 : 0.68) * k;

    for (var i = 0; i < _rocks.length; i++) {
      final rock = _rocks[i];
      rock.w = rock.baseW * rockScale;
      rock.h = rock.baseH * rockScale;
      rock.r = math.max(rock.w, rock.h) * 0.44;

      if (firstInit) {
        rock.x = _galaxyRand(rock.r + 12, math.max(rock.r + 24, s.width - rock.r - 12));
        rock.y = _galaxyRand(rock.r + 12, math.max(rock.r + 24, s.height - rock.r - 12));
        final speed = _galaxyRand(14, 34);
        final dir = _galaxyRand(0, math.pi * 2);
        rock.vx = math.cos(dir) * speed;
        rock.vy = math.sin(dir) * speed;
        rock.angle = _galaxyRand(0, math.pi * 2);
        rock.angVel = _galaxyRand(-0.9, 0.9);
      } else {
        rock.x = rock.x.clamp(rock.r, math.max(rock.r, s.width - rock.r));
        rock.y = rock.y.clamp(rock.r, math.max(rock.r, s.height - rock.r));
      }
    }

    if (firstInit) {
      _planetX = s.width * 0.78;
      _planetY = s.height * 0.34;
    } else {
      _planetX = _planetX.clamp(s.width * 0.55, math.max(s.width * 0.55, s.width - 28));
      _planetY = _planetY.clamp(28, math.max(28, s.height - 28));
    }
  }

  void _impulseAt(Offset pos) {
    for (final rock in _rocks) {
      if (rock.dragging) continue;
      final dx = rock.x - pos.dx;
      final dy = rock.y - pos.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist > 140) continue;
      final inv = dist < 1 ? 1.0 : 1.0 / dist;
      final strength = (1.0 - dist / 140.0) * 120.0 + 35.0;
      rock.vx += dx * inv * strength;
      rock.vy += dy * inv * strength;
      rock.angVel += _galaxyRand(-1.8, 1.8);
    }
  }

  void _step(double dt) {
    _t += dt;
    final w = _size.width;
    final h = _size.height;

    // Gerak pelan planet besar mengambang
    final k = _propScale(w, h);
    final planetMargin = 22.0 * k * 0.62;
    _planetX += _planetVx * dt;
    _planetY += _planetVy * dt;
    final minPx = math.min(w - planetMargin, w * 0.56);
    final maxPx = math.max(minPx, w - planetMargin);
    final minPy = math.min(h - planetMargin, 34.0);
    final maxPy = math.max(minPy, h - planetMargin);

    if (_planetX < minPx) {
      _planetX = minPx;
      _planetVx = _planetVx.abs();
    } else if (_planetX > maxPx) {
      _planetX = maxPx;
      _planetVx = -_planetVx.abs();
    }
    if (_planetY < minPy) {
      _planetY = minPy;
      _planetVy = _planetVy.abs();
    } else if (_planetY > maxPy) {
      _planetY = maxPy;
      _planetVy = -_planetVy.abs();
    }

    // 2 substep fisika asteroid agar pantulan stabil & responsif
    const substeps = 2;
    final sdt = dt / substeps;
    final damping = math.pow(0.992, dt * 60).toDouble();

    for (var s = 0; s < substeps; s++) {
      for (final rock in _rocks) {
        if (rock.dragging) continue;

        rock.x += rock.vx * sdt;
        rock.y += rock.vy * sdt;
        rock.angle += rock.angVel * sdt;

        // Pertahankan energi minimal di nol gravitasi agar tetap hidup
        if (s == 0) {
          rock.vx *= damping;
          rock.vy *= damping;
          final speedSq = rock.vx * rock.vx + rock.vy * rock.vy;
          if (speedSq < 90.0) {
            final boost = 0.35;
            rock.vx += math.cos(_t + rock.mass) * boost;
            rock.vy += math.sin(_t * 1.1 + rock.mass) * boost;
          } else if (speedSq > 260.0 * 260.0) {
            final scale = 260.0 / math.sqrt(speedSq);
            rock.vx *= scale;
            rock.vy *= scale;
          }
        }

        // Pantulan dinding
        if (rock.x - rock.r < 0) {
          rock.x = rock.r;
          rock.vx = rock.vx.abs() * 0.65;
        } else if (rock.x + rock.r > w) {
          rock.x = w - rock.r;
          rock.vx = -rock.vx.abs() * 0.65;
        }

        if (rock.y - rock.r < 0) {
          rock.y = rock.r;
          rock.vy = rock.vy.abs() * 0.65;
        } else if (rock.y + rock.r > h) {
          rock.y = h - rock.r;
          rock.vy = -rock.vy.abs() * 0.65;
        }
      }

      // Kolisi elastis antar-asteroid
      for (var i = 0; i < _rocks.length; i++) {
        for (var j = i + 1; j < _rocks.length; j++) {
          final a = _rocks[i];
          final b = _rocks[j];
          final dx = b.x - a.x;
          final dy = b.y - a.y;
          final minDist = a.r + b.r;
          final distSq = dx * dx + dy * dy;
          if (distSq >= minDist * minDist) continue;

          final dist = math.sqrt(distSq);
          final nx = dist > 0.001 ? dx / dist : 1.0;
          final ny = dist > 0.001 ? dy / dist : 0.0;
          final overlap = minDist - dist;

          final invMassA = a.dragging ? 0.0 : 1.0 / a.mass;
          final invMassB = b.dragging ? 0.0 : 1.0 / b.mass;
          final invMassSum = invMassA + invMassB;
          if (invMassSum <= 0) continue;

          a.x -= nx * overlap * (invMassA / invMassSum);
          a.y -= ny * overlap * (invMassA / invMassSum);
          b.x += nx * overlap * (invMassB / invMassSum);
          b.y += ny * overlap * (invMassB / invMassSum);

          final rvx = b.vx - a.vx;
          final rvy = b.vy - a.vy;
          final velAlongNormal = rvx * nx + rvy * ny;
          if (velAlongNormal > 0) continue;

          const restitution = 0.6;
          final impulse = -(1 + restitution) * velAlongNormal / invMassSum;

          if (!a.dragging) {
            a.vx -= impulse * invMassA * nx;
            a.vy -= impulse * invMassA * ny;
          }
          if (!b.dragging) {
            b.vx += impulse * invMassB * nx;
            b.vy += impulse * invMassB * ny;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : 360.0;
        final cardH = cardW < 500 ? 330.0 : (cardW < 800 ? 295.0 : 275.0);
        final size = Size(cardW, cardH);
        _syncLayout(size);

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: const Color(0xFF05060F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(5, 6, 15, 0.35),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _heroStage(size),
          ),
        );
      },
    );
  }

  Widget _heroStage(Size size) {
    final w = size.width;
    final h = size.height;
    final sc = math.max(w / 640.0, h / 360.0);
    final sw = 640.0 * sc;
    final sh = 360.0 * sc;
    final ax = sw > w * 1.15 ? 1.0 : 0.5;
    final dx = (w - sw) * ax;
    final dy = (h - sh) * 0.5;

    final k = _propScale(w, h);
    final planetBigSize = 43.0 * k * 0.62;
    final planetSmallSize = 16.0 * k * 0.62;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _impulseAt(e.localPosition),
      child: Stack(
        children: [
          // 1. Deep space backdrop
          Positioned(
            left: dx,
            top: dy,
            width: sw,
            height: sh,
            child: IgnorePointer(
              child: Image.asset(
                '$_basePath/BackgroundSpace.webp',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),

          // 2. Blue stars parallax seamless scroll + 3 FPS twinkle + celestial layer
          Positioned.fill(
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _tick,
                  builder: (context, _) {
                    final stripW = h * (272.0 / 160.0);
                    final starScroll = -((_t * 14.0) % stripW);
                    final frameIdx = ((_t * 3.0).floor()) % 4;
                    final bobY = math.sin(_t * 0.85) * 4.0;

                    final orbitAngle = _t * 0.72;
                    final orbitDepth = math.sin(orbitAngle);
                    final moonX =
                        _planetX + math.cos(orbitAngle) * (planetBigSize * 1.15);
                    final moonY =
                        _planetY + math.sin(orbitAngle) * (planetBigSize * 0.36);

                    final moonWidget = Positioned(
                      left: moonX - planetSmallSize / 2,
                      top: moonY - planetSmallSize / 2,
                      width: planetSmallSize,
                      height: planetSmallSize,
                      child: Opacity(
                        opacity: (0.78 + 0.22 * orbitDepth).clamp(0.5, 1.0),
                        child: Transform.scale(
                          scale: 0.86 + 0.14 * orbitDepth,
                          child: Image.asset(
                            '$_basePath/prop-planet-small.webp',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                    );

                    final bigPlanetWidget = Positioned(
                      left: _planetX - planetBigSize / 2,
                      top: _planetY - planetBigSize / 2,
                      width: planetBigSize,
                      height: planetBigSize,
                      child: Image.asset(
                        '$_basePath/prop-planet-big.webp',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    );

                    return Stack(
                      children: [
                        // Looping blue stars strip
                        Positioned(
                          left: starScroll,
                          top: 0,
                          width: stripW,
                          height: h,
                          child: Opacity(
                            opacity: 0.75,
                            child: Image.asset(
                              '$_basePath/blue-stars.webp',
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                        ),
                        Positioned(
                          left: starScroll + stripW,
                          top: 0,
                          width: stripW,
                          height: h,
                          child: Opacity(
                            opacity: 0.75,
                            child: Image.asset(
                              '$_basePath/blue-stars.webp',
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                        ),

                        // Twinkle 4-frame spritesheet (2560x360 -> 4 x 640x360)
                        Positioned(
                          left: dx,
                          top: dy,
                          width: sw,
                          height: sh,
                          child: ClipRect(
                            child: Stack(
                              children: [
                                Positioned(
                                  left: -frameIdx * sw,
                                  top: 0,
                                  width: sw * 4,
                                  height: sh,
                                  child: Image.asset(
                                    '$_basePath/near_stars_twinkle_4frames.webp',
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Ringed planet celestial backdrop bobbing gently
                        Positioned(
                          left: dx,
                          top: dy + bobY,
                          width: sw,
                          height: sh,
                          child: Image.asset(
                            '$_basePath/layer4_celestial.webp',
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.none,
                          ),
                        ),

                        // Orbiting planet & moon depth-sorted
                        if (orbitDepth < 0) moonWidget,
                        bigPlanetWidget,
                        if (orbitDepth >= 0) moonWidget,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // 3. Soft cosmic top scrim for clear white typography
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.55, 1.0],
                    colors: [
                      const Color(0xFF05060F).withValues(alpha: 0.42),
                      Colors.transparent,
                      const Color(0xFF05060F).withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Interactive physics asteroids
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _tick,
              builder: (context, _) => Stack(
                children: [
                  for (final rock in _rocks) _rockWidget(rock),
                ],
              ),
            ),
          ),

          // 5. Shared overlay: Profil Siswa, Kartu Peringkat & EXP, Quick Actions
          Positioned.fill(
            child: HeroDashboardOverlay(
              user: widget.user,
              stats: widget.stats,
              modulCount: widget.modulCount,
              quizCount: widget.quizCount,
              heroTheme: 'galaksi',
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

  Widget _rockWidget(_Asteroid rock) {
    final hitPad = 8.0;
    final boxW = rock.w + hitPad * 2;
    final boxH = rock.h + hitPad * 2;

    return Positioned(
      left: rock.x - boxW / 2,
      top: rock.y - boxH / 2,
      width: boxW,
      height: boxH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          rock.dragging = true;
          rock.vx = 0;
          rock.vy = 0;
        },
        onPanUpdate: (details) {
          rock.x = (rock.x + details.delta.dx)
              .clamp(rock.r, math.max(rock.r, _size.width - rock.r));
          rock.y = (rock.y + details.delta.dy)
              .clamp(rock.r, math.max(rock.r, _size.height - rock.r));
          if (details.delta.distance > 0.1) {
            rock.vx = (details.delta.dx * 36).clamp(-260.0, 260.0);
            rock.vy = (details.delta.dy * 36).clamp(-260.0, 260.0);
          }
        },
        onPanEnd: (details) {
          rock.dragging = false;
          final v = details.velocity.pixelsPerSecond;
          if (v.distance > 20) {
            rock.vx = (v.dx * 0.45).clamp(-260.0, 260.0);
            rock.vy = (v.dy * 0.45).clamp(-260.0, 260.0);
            rock.angVel = ((v.dx - v.dy) * 0.008).clamp(-4.0, 4.0);
          }
        },
        onPanCancel: () {
          rock.dragging = false;
        },
        child: Center(
          child: Transform.rotate(
            angle: rock.angle,
            child: Image.asset(
              rock.asset,
              width: rock.w,
              height: rock.h,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      ),
    );
  }
}
