import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DungeonFloorLoader extends StatefulWidget {
  final int from;
  final int to;
  final Duration duration;
  final VoidCallback onDone;

  const DungeonFloorLoader({
    super.key,
    required this.from,
    required this.to,
    this.duration = const Duration(milliseconds: 3000),
    required this.onDone,
  });

  @override
  State<DungeonFloorLoader> createState() => _DungeonFloorLoaderState();
}

class _DungeonFloorLoaderState extends State<DungeonFloorLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isCompleted = false;

  static const List<String> _messages = [
    'Menyiapkan soal…',
    'Menaiki tangga…',
    'Membuka pintu lantai…',
    'Hampir sampai…',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isCompleted = true);
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted) {
            widget.onDone();
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateProgress(double t) {
    if (t < 0.9) {
      return (1.0 - math.pow(1.0 - (t / 0.9), 1.6)) * 0.92;
    } else {
      return 0.92 + ((t - 0.9) / 0.1) * 0.08;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double t = _controller.value;
    final double p = _calculateProgress(t).clamp(0.0, 1.0);
    final int pct = (p * 100).toInt();

    final String message = _isCompleted
        ? 'Lantai ${widget.to} siap!'
        : _messages[(t * _messages.length).toInt().clamp(0, _messages.length - 1)];

    return Material(
      color: const Color(0xEC030A14), // Dark Navy Backdrop with high opacity
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Judul Lantai (Fredoka 3D)
                Text(
                  'Naik ke Lantai ${widget.to}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0xFF0F3A5F),
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // 2. Subtitle Asal Lantai
                Text(
                  'Dari Lantai ${widget.from}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA9D6F5),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Stage Karakter Runner Pixel
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double runnerWidth = 84;
                      const double runnerHeight = 80;
                      final double maxTravel = constraints.maxWidth - runnerWidth;
                      final double currentLeft = maxTravel * p;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: currentLeft.clamp(0.0, maxTravel),
                            bottom: 0,
                            child: Image.asset(
                              'assets/dungeon/run.gif',
                              width: runnerWidth,
                              height: runnerHeight,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.directions_run_rounded, size: 70, color: Color(0xFF38BDF8)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // 4. Progress Bar Segmented 20 Balok Khas Retro Web
                Container(
                  height: 36,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2237),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCFE9FB), width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF061829),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(20, (index) {
                      final int totalLit = (p * 20).floor();
                      final bool isLit = index < totalLit || _isCompleted;

                      Color blockColor = const Color(0xFF16405F);
                      if (isLit) {
                        blockColor = _isCompleted
                            ? const Color(0xFF34D399) // Emerald jika selesai
                            : const Color(0xFF38BDF8); // Cyan saat memuat
                      }

                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index == 19 ? 0 : 2.5),
                          decoration: BoxDecoration(
                            color: blockColor,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: isLit
                                ? [
                                    BoxShadow(
                                      color: _isCompleted
                                          ? const Color(0xFFA7F3D0).withValues(alpha: 0.8)
                                          : const Color(0xFFBAE6FD).withValues(alpha: 0.8),
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Pesan Status & Persentase
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFCFE9FB),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
