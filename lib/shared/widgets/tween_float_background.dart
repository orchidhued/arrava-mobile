import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Konfigurasi parameter gelombang/partikel mengambang
class FloatCfg {
  final int dur; // ms per siklus naik-turun
  final double ax; // jarak geser kiri-kanan (%)
  final double ay; // jarak geser naik-turun (%)
  final double ph; // fase awal
  final double o; // opacity dasar
  final double heightFactor; // faktor tinggi lapisan

  const FloatCfg({
    required this.dur,
    required this.ax,
    required this.ay,
    required this.ph,
    required this.o,
    required this.heightFactor,
  });
}

/// Widget latar belakang efek piksel mengambang (Tween Float Pixel Effect)
/// Mengikuti lebar penuh beranda dan tinggi dari dashboard secara dinamis.
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
  double _ms = 0.0;

  static const String _imgBg = 'assets/backgorund1.png';
  static const String _imgFloat = 'assets/backgorund3.png';

  static const List<FloatCfg> _floats = [
    FloatCfg(dur: 4200, ax: 5, ay: 12, ph: 0.0, o: 0.55, heightFactor: 1.0),
    FloatCfg(dur: 3000, ax: 4, ay: 10, ph: 0.5, o: 1.0, heightFactor: 1.2),
  ];

  /// Easing sinus halus
  static double _ease(double t) => -(math.cos(math.pi * t) - 1) / 2;

  /// Bolak-balik 0 -> 1 -> 0 seiring waktu
  static double _pingpong(double ms, double d, double ph) {
    final p = ((ms / d) + ph) % 2;
    return p < 1 ? p : 2 - p;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _ms = elapsed.inMicroseconds / 1000.0;
      _frame.value++;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;

        return Stack(
          children: [
            // ===============================================================
            // LAPISAN EFEK (Mengikuti lebar beranda dan tinggi dashboard)
            // ===============================================================
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _frame,
                    builder: (context, _) {
                      // Parallax scroll jika controller aktif
                      final double scrollY = (widget.enableParallax &&
                              widget.scrollController != null &&
                              widget.scrollController!.hasClients)
                          ? widget.scrollController!.offset
                          : 0.0;

                      final double bgParallax1 =
                          (scrollY * 0.08).clamp(0.0, h * 0.25);
                      final double bgParallax2 =
                          (scrollY * 0.16).clamp(0.0, h * 0.35);
                      final double floatParallax =
                          (scrollY * 0.22).clamp(0.0, h * 0.40);

                      return Stack(
                        children: [
                          // 1. Latar Belakang Lapisan 1 (assets/backgorund1.png)
                          Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(0, -bgParallax1),
                              child: Opacity(
                                opacity: widget.bgOpacity,
                                child: _pixelImage(_imgBg, fit: BoxFit.cover),
                              ),
                            ),
                          ),

                          // 2. Latar Belakang Lapisan 2 (dicerminkan, kedalaman ganda)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.45 * widget.bgOpacity,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.translationValues(
                                  0,
                                  -bgParallax2,
                                  0,
                                )..scaleByDouble(-1.2, 1.2, 1.0, 1.0),
                                child: _pixelImage(_imgBg, fit: BoxFit.cover),
                              ),
                            ),
                          ),

                          // 3. Lapisan Partikel Mengambang (assets/backgorund3.png)
                          ..._floats.map((l) {
                            final double layerW = w * 1.15;
                            final double layerH = h * l.heightFactor;

                            final double ex = _ease(
                                  _pingpong(_ms, l.dur * 1.3, l.ph),
                                ) *
                                2.0 -
                                1.0;
                            final double ey = _ease(
                                  _pingpong(_ms, l.dur.toDouble(), 0),
                                ) *
                                2.0 -
                                1.0;

                            final double floatX = ex * l.ax / 100.0 * layerW;
                            final double floatY = -ey * l.ay / 100.0 * layerH;

                            return Positioned(
                              left: w * (-0.075),
                              width: layerW,
                              height: layerH,
                              bottom: h * (-0.12),
                              child: Transform.translate(
                                offset: Offset(
                                  floatX,
                                  floatY - floatParallax,
                                ),
                                child: Opacity(
                                  opacity: (l.o * widget.bgOpacity)
                                      .clamp(0.0, 1.0),
                                  child: _pixelImage(
                                    _imgFloat,
                                    fit: BoxFit.fill,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // 4. Lapisan Overlay Opsional (untuk kontras teks)
                          if (widget.overlayColor != null)
                            Positioned.fill(
                              child: ColoredBox(color: widget.overlayColor!),
                            ),
                        ],
                      );
                    },
                  ),
                ),
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
      },
    );
  }
}

