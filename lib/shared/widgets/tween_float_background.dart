import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Data partikel gelembung mengambang laut
class _OceanParticle {
  final double xPct;
  final double radius;
  final double speed;
  final double driftFreq;
  final double driftAmp;
  final double baseOpacity;
  final Color color;

  double yPct;

  _OceanParticle({
    required this.xPct,
    required this.yPct,
    required this.radius,
    required this.speed,
    required this.driftFreq,
    required this.driftAmp,
    required this.baseOpacity,
    required this.color,
  });
}

/// Widget latar belakang efek gelombang & partikel samudra (Modern Oceanic Ambient)
/// Mengikuti lebar penuh layar dan memberikan kedalaman visual yang tenang & profesional
/// tanpa mengganggu keterbacaan teks atau kartu utama.
class TweenFloatBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final bool enableParallax;
  final double bgOpacity;
  final Color? overlayColor;

  const TweenFloatBackground({
    super.key,
    required this.child,
    this.scrollController,
    this.enableParallax = true,
    this.bgOpacity = 1.0,
    this.overlayColor,
  });

  @override
  State<TweenFloatBackground> createState() => _TweenFloatBackgroundState();
}

class _TweenFloatBackgroundState extends State<TweenFloatBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  double _timeSec = 0.0;
  Duration _lastElapsed = Duration.zero;

  late final List<_OceanParticle> _particles;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _ticker = createTicker(_onTick)..start();
  }

  void _initParticles() {
    final rng = math.Random(42); // Seed konsisten
    const particleCount = 18;
    _particles = List.generate(particleCount, (i) {
      final isCyan = rng.nextBool();
      return _OceanParticle(
        xPct: rng.nextDouble(),
        yPct: rng.nextDouble(),
        radius: 3.5 + rng.nextDouble() * 5.5,
        speed: 0.025 + rng.nextDouble() * 0.045,
        driftFreq: 1.2 + rng.nextDouble() * 1.5,
        driftAmp: 6.0 + rng.nextDouble() * 12.0,
        baseOpacity: 0.22 + rng.nextDouble() * 0.28,
        color: isCyan ? const Color(0xFF51CDF4) : const Color(0xFF007FBE),
      );
    });
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(0.001, 0.05);
    _lastElapsed = elapsed;
    _timeSec += dt;

    // Update posisi partikel naik ke atas
    for (final p in _particles) {
      p.yPct -= p.speed * dt;
      if (p.yPct < 0.0) {
        p.yPct = 1.0;
      }
    }

    _frame.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ===============================================================
        // LAPISAN AMBIENT GELOMBANG & PARTIKEL SAMUDRA (DI BELAKANG KONTEN)
        // ===============================================================
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _frame,
              builder: (context, _) {
                final double scrollY = (widget.enableParallax &&
                        widget.scrollController != null &&
                        widget.scrollController!.hasClients)
                    ? widget.scrollController!.offset
                    : 0.0;

                return CustomPaint(
                  painter: _OceanAmbientPainter(
                    time: _timeSec,
                    scrollY: scrollY,
                    bgOpacity: widget.bgOpacity,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
        ),

        // ===============================================================
        // OVERLAY WARNA OPSIONAL
        // ===============================================================
        if (widget.overlayColor != null)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: widget.overlayColor!),
            ),
          ),

        // ===============================================================
        // KONTEN UTAMA DASHBOARD
        // ===============================================================
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

/// Custom Painter untuk menggambar gelombang samudra halus & partikel ambient
class _OceanAmbientPainter extends CustomPainter {
  final double time;
  final double scrollY;
  final double bgOpacity;
  final List<_OceanParticle> particles;

  _OceanAmbientPainter({
    required this.time,
    required this.scrollY,
    required this.bgOpacity,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Batasi tinggi area gelombang di 30% layar bagian bawah
    final waveBaseH = (h * 0.28).clamp(160.0, 280.0);
    final parallax = (scrollY * 0.08).clamp(0.0, 45.0);

    final baseY = h - waveBaseH + parallax;

    // 1. Gambar Gelombang Lapis 1 (Deep Ocean Wave - Paling Belakang)
    _drawSmoothWave(
      canvas: canvas,
      width: w,
      height: h,
      baseY: baseY + 30,
      amplitude: 14.0,
      frequency: 0.007,
      speed: 0.7,
      phase: 0.0,
      color: const Color(0xFFBAE6FD).withValues(alpha: 0.22 * bgOpacity),
    );

    // 2. Gambar Gelombang Lapis 2 (Mid Ocean Wave - Tengah)
    _drawSmoothWave(
      canvas: canvas,
      width: w,
      height: h,
      baseY: baseY + 14,
      amplitude: 11.0,
      frequency: 0.009,
      speed: -0.9,
      phase: 2.2,
      color: const Color(0xFF7DD3FC).withValues(alpha: 0.18 * bgOpacity),
    );

    // 3. Gambar Gelombang Lapis 3 (Front Crest Wave - Depan)
    _drawSmoothWave(
      canvas: canvas,
      width: w,
      height: h,
      baseY: baseY,
      amplitude: 8.0,
      frequency: 0.011,
      speed: 1.1,
      phase: 4.1,
      color: const Color(0xFFE0F2FE).withValues(alpha: 0.32 * bgOpacity),
    );

    // 4. Gambar Partikel Gelembung Ambient (Hanya muncul di 45% bagian bawah layar)
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final p in particles) {
      // Petakan yPct ke 50% bagian bawah layar agar tidak naik ke atas kartu
      final py = h - (p.yPct * (h * 0.45));
      final drift = math.sin(time * p.driftFreq + p.xPct * 10) * p.driftAmp;
      final px = (p.xPct * w + drift) % w;

      // Efek fade-out saat partikel naik mendekati bagian tengah layar
      final fadeFactor = (1.0 - (1.0 - p.yPct)).clamp(0.0, 1.0);
      final alpha = (p.baseOpacity * fadeFactor * bgOpacity).clamp(0.0, 1.0);

      particlePaint.color = p.color.withValues(alpha: alpha * 0.45);
      canvas.drawCircle(Offset(px, py), p.radius, particlePaint);

      // Cincin halus gelembung
      strokePaint.color = p.color.withValues(alpha: alpha * 0.75);
      canvas.drawCircle(Offset(px, py), p.radius, strokePaint);
    }
  }

  void _drawSmoothWave({
    required Canvas canvas,
    required double width,
    required double height,
    required double baseY,
    required double amplitude,
    required double frequency,
    required double speed,
    required double phase,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, height);
    path.lineTo(0, baseY);

    const step = 8.0; // Interval sampling kurva halus
    for (double x = 0; x <= width; x += step) {
      final y = baseY + math.sin(x * frequency + (time * speed) + phase) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OceanAmbientPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.scrollY != scrollY ||
        oldDelegate.bgOpacity != bgOpacity;
  }
}
