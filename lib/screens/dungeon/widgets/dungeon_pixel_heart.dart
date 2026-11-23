import 'package:flutter/material.dart';

class PixelHeartSprite extends StatelessWidget {
  final double size;
  final String state; // 'full', 'shine', 'lost', 'dead'
  final int frameIndex;

  const PixelHeartSprite({
    super.key,
    this.size = 64,
    required this.state,
    this.frameIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (state == 'dead') {
      return Image.asset(
        'assets/dungeon/nyawa/heart-dead.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );
    }

    if (state == 'full') {
      return Image.asset(
        'assets/dungeon/nyawa/heart-full.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );
    }

    if (state == 'shine') {
      const int totalFrames = 9;
      final int f = frameIndex % totalFrames;
      return ClipRect(
        child: SizedBox(
          width: size,
          height: size,
          child: OverflowBox(
            maxWidth: size * totalFrames,
            maxHeight: size,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(-f * size, 0),
              child: Image.asset(
                'assets/dungeon/nyawa/heart-shine.png',
                width: size * totalFrames,
                height: size,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        ),
      );
    }

    if (state == 'lost') {
      const int totalFrames = 12;
      final int f = frameIndex.clamp(0, totalFrames - 1);
      return ClipRect(
        child: SizedBox(
          width: size,
          height: size,
          child: OverflowBox(
            maxWidth: size * totalFrames,
            maxHeight: size,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(-f * size, 0),
              child: Image.asset(
                'assets/dungeon/nyawa/heart-lost.png',
                width: size * totalFrames,
                height: size,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(width: size, height: size);
  }
}
