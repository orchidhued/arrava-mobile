import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LauncherService {
  static const MethodChannel _channel = MethodChannel('com.arrava.app/launcher');

  /// Membuka URL eksternal (YouTube, Browser, dsb.)
  static Future<bool> openUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    try {
      final bool? success = await _channel.invokeMethod<bool>('openUrl', {'url': trimmed});
      return success ?? false;
    } catch (e) {
      debugPrint('LauncherService.openUrl error: $e');
      return false;
    }
  }

  /// Membuka file atau dokumen PDF menggunakan PDF viewer bawaan / fallback browser
  static Future<bool> openPdf(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    try {
      final bool? success = await _channel.invokeMethod<bool>('openPdf', {'url': trimmed});
      return success ?? false;
    } catch (e) {
      debugPrint('LauncherService.openPdf error: $e');
      // Fallback ke browser via openUrl
      return await openUrl(trimmed);
    }
  }

  /// Membuka dokumen PDF menggunakan Google Docs Online Viewer (100% aman tanpa perlu aplikasi PDF viewer)
  static Future<bool> openGoogleDocsPdf(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    final viewerUrl = 'https://docs.google.com/viewer?url=${Uri.encodeComponent(trimmed)}';
    return await openUrl(viewerUrl);
  }
}

