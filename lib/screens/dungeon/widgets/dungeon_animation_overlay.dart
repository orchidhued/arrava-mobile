import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dungeon_pixel_heart.dart';

enum DungeonAnimType { start, loseLife }

class DungeonAnimationOverlay extends StatefulWidget {
  final DungeonAnimType type;
  final int prevLives;
  final int newLives;
  final bool isTimeout;
  final VoidCallback onComplete;

  const DungeonAnimationOverlay({
    super.key,
    required this.type,
    this.prevLives = 3,
    this.newLives = 3,
    this.isTimeout = false,
    required this.onComplete,
  });

  @override
  State<DungeonAnimationOverlay> createState() => _DungeonAnimationOverlayState();
}

class _DungeonAnimationOverlayState extends State<DungeonAnimationOverlay>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animasi Shake
  late AnimationController _shakeController;

  // Animasi Drop Hati (3 Hati)
  late AnimationController _dropController1;
  late AnimationController _dropController2;
  late AnimationController _dropController3;

  // Frame Ticker untuk Sprite Hati
  Timer? _tickerTimer;
  int _shineFrame0 = 0;
  int _shineFrame1 = 3;
  int _shineFrame2 = 6;
  int _lostFrame = 0;
  bool _lostCompleted = false;

  // Status Teks Countdown / Hasil
  String _countdownText = '';
  Color _countdownColor = const Color(0xFFFFD84D);
  Color _countdownShadow = const Color(0xFFB38600);
  double _countdownScale = 1.0;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _dropController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _dropController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _dropController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.type == DungeonAnimType.start) {
      _startStartAnimation();
    } else {
      _startLoseLifeAnimation();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tickerTimer?.cancel();
    _shakeController.dispose();
    _dropController1.dispose();
    _dropController2.dispose();
    _dropController3.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String assetPath) {
    try {
      _audioPlayer.stop();
      _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {}
  }

  // ===========================================================================
  // 1. ANIMASI MULAI PETUALANGAN (Drop Hearts + 3 2 1 MULAI!)
  // ===========================================================================
  void _startStartAnimation() {
    // 1. Drop Hati 1
    _dropController1.forward();

    // 2. Drop Hati 2 setelah 250ms
    Timer(const Duration(milliseconds: 250), () {
      if (!_isDisposed) _dropController2.forward();
    });

    // 3. Drop Hati 3 setelah 500ms
    Timer(const Duration(milliseconds: 500), () {
      if (!_isDisposed) _dropController3.forward();
    });

    // 4. Mulai Sprite Shimmering Ticker setelah hati mendarat
    Timer(const Duration(milliseconds: 1400), () {
      if (_isDisposed) return;
      _tickerTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }
        setState(() {
          _shineFrame0 = (_shineFrame0 + 1) % 9;
          _shineFrame1 = (_shineFrame1 + 1) % 9;
          _shineFrame2 = (_shineFrame2 + 1) % 9;
        });
      });
    });

    // 5. Mulai Countdown 3, 2, 1, MULAI!
    Timer(const Duration(milliseconds: 1500), () {
      if (_isDisposed) return;
      _runCountdownSequence();
    });
  }

  void _runCountdownSequence() async {
    final steps = [
      {'text': '3', 'color': const Color(0xFFFFD84D), 'shadow': const Color(0xFFB38600), 'dur': 700},
      {'text': '2', 'color': const Color(0xFFFFD84D), 'shadow': const Color(0xFFB38600), 'dur': 700},
      {'text': '1', 'color': const Color(0xFFFFD84D), 'shadow': const Color(0xFFB38600), 'dur': 700},
      {'text': 'MULAI!', 'color': const Color(0xFF10B981), 'shadow': const Color(0xFF065F46), 'dur': 550},
    ];

    // Bunyikan suara mulai pada angka 3
    _playSound('sounds/dungeon/suaraMulaiDungeon.mp3');

    for (final step in steps) {
      if (_isDisposed) return;
      setState(() {
        _countdownText = step['text'] as String;
        _countdownColor = step['color'] as Color;
        _countdownShadow = step['shadow'] as Color;
        _countdownScale = 1.35;
      });

      // Animate scale bounce
      await Future.delayed(const Duration(milliseconds: 120));
      if (_isDisposed) return;
      setState(() => _countdownScale = 1.0);

      await Future.delayed(Duration(milliseconds: (step['dur'] as int) - 120));
    }

    if (!_isDisposed) {
      widget.onComplete();
    }
  }

  // ===========================================================================
  // 2. ANIMASI KEHILANGAN HATI (Screen Shake + Heart Break + YOU LOSE / -1 HATI)
  // ===========================================================================
  void _startLoseLifeAnimation() {
    _playSound('sounds/dungeon/kehilanganNyawaSound.mp3');
    _shakeController.forward(from: 0.0);

    // Jalankan ticker frame untuk animasi pecahan hati (12 frame)
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (_lostFrame < 11) {
        setState(() => _lostFrame++);
      } else {
        timer.cancel();
        setState(() => _lostCompleted = true);
        _handleLoseText();
      }
    });
  }

  void _handleLoseText() async {
    if (_isDisposed) return;

    if (widget.newLives <= 0) {
      setState(() {
        _countdownText = 'YOU LOSE';
        _countdownColor = const Color(0xFFF43F5E);
        _countdownShadow = const Color(0xFF6B0F1A);
        _countdownScale = 1.3;
      });
      await Future.delayed(const Duration(milliseconds: 1400));
    } else {
      setState(() {
        _countdownText = '-1 HATI (SISA ${widget.newLives})';
        _countdownColor = const Color(0xFFFFD84D);
        _countdownShadow = const Color(0xFFB38600);
        _countdownScale = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 850));
    }

    if (!_isDisposed) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            double shakeOffset = 0.0;
            if (_shakeController.isAnimating) {
              final val = _shakeController.value;
              shakeOffset = 14 * (1.0 - val) * ((val * 16 % 2 == 0) ? 1 : -1);
            }
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Judul Animasi
                Text(
                  widget.type == DungeonAnimType.start
                      ? 'PETUALANGAN DUNGEON'
                      : (widget.isTimeout ? '⏳ WAKTU HABIS!' : '❌ JAWABAN SALAH!'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: widget.type == DungeonAnimType.start
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFFF43F5E),
                    shadows: [
                      Shadow(
                        color: widget.type == DungeonAnimType.start
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF6B0F1A),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Barisan 3 Hati Pixel Interaktif
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (idx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildHeartItem(idx),
                    );
                  }),
                ),

                const SizedBox(height: 36),

                // Teks Countdown (3, 2, 1, MULAI! / YOU LOSE / -1 HATI)
                AnimatedScale(
                  scale: _countdownScale,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  child: SizedBox(
                    height: 70,
                    child: Center(
                      child: Text(
                        _countdownText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: widget.newLives <= 0 && widget.type == DungeonAnimType.loseLife
                              ? 34
                              : 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: _countdownColor,
                          shadows: [
                            Shadow(
                              color: _countdownShadow,
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: _countdownColor.withValues(alpha: 0.6),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeartItem(int idx) {
    const double heartSize = 72;

    if (widget.type == DungeonAnimType.start) {
      // Pada mode start: animasi drop satu per satu
      AnimationController controller;
      int frame;
      if (idx == 0) {
        controller = _dropController1;
        frame = _shineFrame0;
      } else if (idx == 1) {
        controller = _dropController2;
        frame = _shineFrame1;
      } else {
        controller = _dropController3;
        frame = _shineFrame2;
      }

      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final double val = controller.value;
          final double translateY = (1.0 - CurvedAnimation(parent: controller, curve: Curves.bounceOut).value) * -400;
          final double opacity = val.clamp(0.0, 1.0);

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: PixelHeartSprite(
                size: heartSize,
                state: val >= 1.0 ? 'shine' : 'full',
                frameIndex: frame,
              ),
            ),
          );
        },
      );
    } else {
      // Pada mode loseLife: hati yang hilang memecah menjadi dead
      final int targetIdx = (widget.prevLives - 1).clamp(0, 2);

      if (idx < targetIdx) {
        // Hati sebelum target: tetap hidup dan bersinar
        return PixelHeartSprite(
          size: heartSize,
          state: 'shine',
          frameIndex: _shineFrame0,
        );
      } else if (idx == targetIdx) {
        // Hati target: animasi pecah (lost) sampai selesai jadi dead
        if (_lostCompleted) {
          return const PixelHeartSprite(
            size: heartSize,
            state: 'dead',
          );
        } else {
          return PixelHeartSprite(
            size: heartSize,
            state: 'lost',
            frameIndex: _lostFrame,
          );
        }
      } else {
        // Hati setelah target: sudah mati sebelumnya
        return const PixelHeartSprite(
          size: heartSize,
          state: 'dead',
        );
      }
    }
  }
}
