import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String _role = 'siswa';

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get role => _role;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get todayNotifications =>
      _notifications.where((n) => n.kategori == 'hari_ini').toList();

  List<NotificationModel> get missedNotifications =>
      _notifications.where((n) => n.kategori == 'terlewat').toList();

  /// Mengambil notifikasi presensi dari server
  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final res = await NotificationService.fetchNotifications();
      if (res['success'] == true) {
        _notifications = (res['notifikasi'] as List<NotificationModel>?) ?? [];
        _role = res['role']?.toString() ?? 'siswa';
        _error = null;
      } else if (res['error'] != null) {
        _error = res['error'].toString();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menandai satu notifikasi sebagai telah dibaca
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      await NotificationService.markRead(id);
    }
  }

  /// Menandai semua notifikasi sebagai telah dibaca
  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) return;

    bool hasUnread = _notifications.any((n) => !n.isRead);
    if (!hasUnread) return;

    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    await NotificationService.markAllRead();
  }

  /// Menghapus data saat logout
  void clear() {
    _notifications = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

