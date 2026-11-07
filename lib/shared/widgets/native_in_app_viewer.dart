import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget pemutar video YouTube/MP4 & pembaca PDF interaktif langsung di dalam aplikasi (In-App)
class NativeInAppViewer extends StatelessWidget {
  final String? youtubeId;
  final String? videoUrl;
  final bool isPdf;
  final double height;

  const NativeInAppViewer({
    super.key,
    this.youtubeId,
    this.videoUrl,
    this.isPdf = false,
    this.height = 210,
  });

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const String viewType = 'com.arrava.app/video_player';
      final Map<String, dynamic> creationParams = <String, dynamic>{
        'youtubeId': youtubeId,
        'videoUrl': videoUrl,
        'isPdf': isPdf,
      };

      return Container(
        height: height,
        width: double.infinity,
        color: Colors.black,
        child: AndroidView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Text(
          'Media player in-app hanya tersedia di Android',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

