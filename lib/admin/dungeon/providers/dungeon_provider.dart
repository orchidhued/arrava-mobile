import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../services/dungeon_services.dart';

class DungeonProvider with ChangeNotifier {
  // ---------------------------------------------------------------------------
  // STATE LOBBY
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> _dungeons = [];
  List<Map<String, dynamic>> get dungeons => UnmodifiableListView(_dungeons);

  int _activeIdx = 0;
  int get activeIdx => _activeIdx;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // STATE GAMEPLAY ARENA
  // ---------------------------------------------------------------------------
  Map<String, dynamic>? _soalAktif;
  Map<String, dynamic>? get soalAktif => _soalAktif;

  int _nyawa = 3;
  int get nyawa => _nyawa;

  int _lantai = 1;
  int get lantai => _lantai;

  int _skor = 0;
  int get skor => _skor;

  int _combo = 0;
  int get combo => _combo;

  double _multiplier = 1.0;
  double get multiplier => _multiplier;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  String _cleanError(Object e) => e.toString().replaceFirst('Exception: ', '');

  void setActiveIdx(int idx) {
    if (_activeIdx != idx && idx >= 0 && idx < _dungeons.length) {
      _activeIdx = idx;
      _safeNotify();
    }
  }

  // ---------------------------------------------------------------------------
  // AKSI LOBBY
  // ---------------------------------------------------------------------------

  Future<void> fetchDungeons() async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final list = await DungeonService.fetchDungeonList();
      _dungeons = list;

      // Pilih mapel pertama yang ada sesi aktif, atau mapel pertama yang terbuka
      final activeSessionIdx = list.indexWhere((d) => d['ada_sesi_aktif'] == true);
      if (activeSessionIdx != -1) {
        _activeIdx = activeSessionIdx;
      } else {
        final firstUnlocked = list.indexWhere((d) => d['terbuka'] == true);
        _activeIdx = firstUnlocked != -1 ? firstUnlocked : 0;
      }
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  // ---------------------------------------------------------------------------
  // AKSI GAMEPLAY ARENA
  // ---------------------------------------------------------------------------

  Future<bool> mulaiPetualangan(int idMapel) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final res = await DungeonService.mulaiPetualangan(idMapel);
      final Map<String, dynamic> sesi = res['sesi'] is Map
          ? Map<String, dynamic>.from(res['sesi'] as Map)
          : <String, dynamic>{};
      final Map<String, dynamic>? soal = res['soal'] is Map
          ? Map<String, dynamic>.from(res['soal'] as Map)
          : null;

      _soalAktif = soal;
      _nyawa = (sesi['nyawa_tersisa'] as num?)?.toInt() ?? 3;
      _lantai = (sesi['lantai_tertinggi'] as num?)?.toInt() ?? 1;
      _skor = (sesi['skor_dungeon'] as num?)?.toInt() ?? 0;
      _combo = (sesi['combo'] as num?)?.toInt() ?? 0;
      _multiplier = (sesi['multiplier'] as num?)?.toDouble() ?? 1.0;
      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<Map<String, dynamic>> jawabSoal({
    required int idMapel,
    required dynamic jawaban,
  }) async {
    if (_isSubmitting || _soalAktif == null) return {};

    _isSubmitting = true;
    _safeNotify();

    try {
      final int idSoal = (_soalAktif!['id_soal'] as num?)?.toInt() ?? 0;
      final hasil = await DungeonService.jawabSoal(
        idMapel: idMapel,
        idSoal: idSoal,
        jawaban: jawaban,
      );

      final Map<String, dynamic>? statusSesi = hasil['status_sesi'] is Map
          ? Map<String, dynamic>.from(hasil['status_sesi'] as Map)
          : null;

      final int sisaNyawa = (statusSesi?['nyawa'] as num?)?.toInt()
          ?? (hasil['nyawa_tersisa'] as num?)?.toInt()
          ?? _nyawa;
      final int skorTotal = (statusSesi?['skor_dungeon'] as num?)?.toInt()
          ?? (hasil['skor_total'] as num?)?.toInt()
          ?? _skor;
      final int combo = (statusSesi?['jumlah_benar'] as num?)?.toInt()
          ?? (hasil['combo'] as num?)?.toInt()
          ?? 0;
      final double multiplier = (statusSesi?['multiplier'] as num?)?.toDouble()
          ?? (hasil['multiplier'] as num?)?.toDouble()
          ?? 1.0;
      final int lantaiBerikutnya = (statusSesi?['lantai'] as num?)?.toInt()
          ?? (hasil['lantai_berikutnya'] as num?)?.toInt()
          ?? _lantai;
      final soalBerikutnya = hasil['soal_berikutnya'] is Map
          ? Map<String, dynamic>.from(hasil['soal_berikutnya'] as Map)
          : null;

      _nyawa = sisaNyawa;
      _skor = skorTotal;
      _combo = combo;
      _multiplier = multiplier;
      _lantai = lantaiBerikutnya;
      _soalAktif = soalBerikutnya;

      return hasil;
    } catch (e) {
      _error = _cleanError(e);
      rethrow;
    } finally {
      _isSubmitting = false;
      _safeNotify();
    }
  }

  Future<void> selesaiPetualangan(int idMapel) async {
    try {
      await DungeonService.selesaiPetualangan(idMapel);
    } catch (_) {}
  }
}
