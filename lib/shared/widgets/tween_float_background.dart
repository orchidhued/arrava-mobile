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
    FloatCfg(dur: 4200, ax: 2.8, ay: 6.0, ph: 0.0, o: 0.50, heightFactor: 0.88),
    FloatCfg(dur: 3000, ax: 2.4, ay: 5.0, ph: 0.5, o: 0.70, heightFactor: 1.0),
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
    BoxFit fit = BoxFit.fitHeight,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    return Image.asset(
      path,
      fit: fit,
      repeat: repeat,
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
        final double h = constraints.maxHeight;

        return Stack(
          children: [
            // ===============================================================
            // LAPISAN EFEK (Mengikuti lebar beranda dan tinggi dashboard)
            // ===============================================================
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRect(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                        ],
                        stops: [0.0, 0.45],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: AnimatedBuilder(
                      animation: _frame,
                      builder: (context, _) {
                        // Parallax scroll jika controller aktif (terkunci di bawah viewport seperti web)
                        final double scrollY = (widget.enableParallax &&
                                widget.scrollController != null &&
                                widget.scrollController!.hasClients)
                            ? widget.scrollController!.offset
                            : 0.0;

                        final double bgBaseH = (h * 0.40).clamp(260.0, 400.0);
                      final double bgParallax1 = (scrollY * 0.08).clamp(0.0, 45.0);
                      final double bgParallax2 = (scrollY * 0.10).clamp(0.0, 55.0);
                      final double floatParallax = (scrollY * 0.09).clamp(0.0, 50.0);

                      return Stack(
                        children: [
                          // 1. Latar Belakang Lapisan 1 (assets/backgorund1.png)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -20,
                            height: bgBaseH + 20,
                            child: Transform.translate(
                              offset: Offset(0, -bgParallax1),
                              child: Opacity(
                                opacity: (0.42 * widget.bgOpacity).clamp(0.0, 1.0),
                                child: _pixelImage(
                                  _imgBg,
                                  fit: BoxFit.fitHeight,
                                  repeat: ImageRepeat.repeatX,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          // 2. Latar Belakang Lapisan 2 (dicerminkan, kedalaman ganda)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -20,
                            height: bgBaseH * 1.06 + 20,
                            child: Transform.translate(
                              offset: Offset(30, -bgParallax2),
                              child: Opacity(
                                opacity: (0.24 * widget.bgOpacity).clamp(0.0, 1.0),
                                child: Transform(
                                  alignment: Alignment.bottomCenter,
                                  transform: Matrix4.identity()
                                    ..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
                                  child: _pixelImage(
                                    _imgBg,
                                    fit: BoxFit.fitHeight,
                                    repeat: ImageRepeat.repeatX,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 3. Lapisan Partikel Mengambang (assets/backgorund3.png)
                          ..._floats.map((l) {
                            final double layerH =
                                (bgBaseH * l.heightFactor).clamp(160.0, 320.0);

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

                            final double floatX = ex * (l.ax * 4.5);
                            final double floatY = -ey * (l.ay * 2.2);

                            return Positioned(
                              left: -40,
                              right: -40,
                              bottom: -15,
                              height: layerH + 15,
                              child: Transform.translate(
                                offset: Offset(
                                  floatX,
                                  floatY - floatParallax,
                                ),
                                child: Opacity(
                                  opacity:
                                      (l.o * widget.bgOpacity).clamp(0.0, 1.0),
                                  child: _pixelImage(
                                    _imgFloat,
                                    fit: BoxFit.fitHeight,
                                    repeat: ImageRepeat.repeatX,
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

