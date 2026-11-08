import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  /// Mengambil daftar notifikasi presensi terbaru dari server
  static Future<Map<String, dynamic>> fetchNotifications() async {
    try {
      final response = await ApiClient.get(ApiConstants.notifikasiCheck);
      if (response is Map<String, dynamic> && response['success'] == true) {
        final listRaw = response['notifikasi'] as List? ?? [];
        final serverReadIds = (response['serverReadIds'] as List? ?? [])
            .map((e) => e.toString())
            .toSet();

        final notifikasi = listRaw.map((raw) {
          final map = Map<String, dynamic>.from(raw as Map);
          final id = map['id']?.toString() ?? '';
          if (serverReadIds.contains(id)) {
            map['is_read'] = true;
          }
          return NotificationModel.fromJson(map);
        }).toList();

        final unreadCount = notifikasi.where((n) => !n.isRead).length;

        return {
          'success': true,
          'notifikasi': notifikasi,
          'unreadCount': unreadCount,
          'serverReadIds': serverReadIds.toList(),
          'role': response['role']?.toString() ?? 'siswa',
        };
      }
      return {
        'success': false,
        'notifikasi': <NotificationModel>[],
        'unreadCount': 0,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] fetchNotifications error: $e');
      }
      return {
        'success': false,
        'notifikasi': <NotificationModel>[],
        'unreadCount': 0,
        'error': e.toString(),
      };
    }
  }

  /// Menandai satu notifikasi sebagai telah dibaca
  static Future<bool> markRead(String id) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.notifikasiMarkRead,
        body: {'id': id},
      );
      return response is Map && response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] markRead error: $e');
      }
      return false;
    }
  }

  /// Menandai semua notifikasi sebagai telah dibaca
  static Future<bool> markAllRead() async {
    try {
      final response = await ApiClient.post(
        ApiConstants.notifikasiMarkRead,
        body: {'all': true},
      );
      return response is Map && response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] markAllRead error: $e');
      }
      return false;
    }
  }
}

