import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keySoundEnabled = 'pref_sound_enabled';
  static const String _keyHapticEnabled = 'pref_haptic_enabled';
  static const String _keyBgmEnabled = 'pref_bgm_enabled';
  static const String _keyHeroTheme = 'pref_hero_theme';
  static const String _draftPrefix = 'quiz_draft_';

  static SharedPreferences? _prefs;

  /// Inisialisasi SharedPreferences jika belum tersedia
  static Future<SharedPreferences> _getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --------------------------------------------------------------------------
  // PENGATURAN AUDIO & HAPTIC
  // --------------------------------------------------------------------------

  /// Memeriksa apakah efek suara kuis diaktifkan (default: true)
  static Future<bool> isSoundEnabled() async {
    final prefs = await _getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  /// Mengubah pengaturan efek suara
  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await _getInstance();
    await prefs.setBool(_keySoundEnabled, enabled);
  }

  /// Memeriksa apakah getaran/haptic diaktifkan (default: true)
  static Future<bool> isHapticEnabled() async {
    final prefs = await _getInstance();
    return prefs.getBool(_keyHapticEnabled) ?? true;
  }

  /// Mengubah pengaturan getaran/haptic
  static Future<void> setHapticEnabled(bool enabled) async {
    final prefs = await _getInstance();
    await prefs.setBool(_keyHapticEnabled, enabled);
  }

  /// Memeriksa apakah musik latar kuis (BGM) diaktifkan (default: true)
  static Future<bool> isBgmEnabled() async {
    final prefs = await _getInstance();
    return prefs.getBool(_keyBgmEnabled) ?? true;
  }

  /// Mengubah pengaturan musik latar kuis
  static Future<void> setBgmEnabled(bool enabled) async {
    final prefs = await _getInstance();
    await prefs.setBool(_keyBgmEnabled, enabled);
  }

  // --------------------------------------------------------------------------
  // AUTO-SAVE DRAFT JAWABAN KUIS (ANTI-CRASH)
  // --------------------------------------------------------------------------

  /// Menyimpan progres jawaban kuis sementara
  static Future<void> saveQuizDraft({
    required int quizId,
    required Map<int, String> answers,
    required int currentIndex,
    int? remainingSeconds,
  }) async {
    try {
      final prefs = await _getInstance();
      // Konversi key int ke string untuk JSON serialization
      final stringAnswers = answers.map((key, value) => MapEntry(key.toString(), value));
      final payload = {
        'quizId': quizId,
        'answers': stringAnswers,
        'currentIndex': currentIndex,
        'remainingSeconds': remainingSeconds,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString('$_draftPrefix$quizId', jsonEncode(payload));
    } catch (_) {}
  }

  /// Mengambil draft kuis jika ada
  static Future<Map<String, dynamic>?> getQuizDraft(int quizId) async {
    try {
      final prefs = await _getInstance();
      final raw = prefs.getString('$_draftPrefix$quizId');
      if (raw == null || raw.isEmpty) return null;

      final Map<String, dynamic> decoded = jsonDecode(raw);
      final rawAnswers = decoded['answers'] as Map<String, dynamic>? ?? {};

      // Map kembali key string ke int
      final Map<int, String> answers = {};
      rawAnswers.forEach((key, value) {
        final intKey = int.tryParse(key);
        if (intKey != null && value is String) {
          answers[intKey] = value;
        }
      });

      return {
        'quizId': decoded['quizId'],
        'answers': answers,
        'currentIndex': decoded['currentIndex'] as int? ?? 0,
        'remainingSeconds': decoded['remainingSeconds'] as int?,
        'updatedAt': decoded['updatedAt'] as String?,
      };
    } catch (_) {
      return null;
    }
  }

  /// Memeriksa apakah ada draft kuis yang belum disubmit
  static Future<bool> hasQuizDraft(int quizId) async {
    final prefs = await _getInstance();
    return prefs.containsKey('$_draftPrefix$quizId');
  }

  /// Memeriksa tema hero dashboard yang tersimpan (default: 'samudra').
  static Future<String> getHeroTheme() async {
    final prefs = await _getInstance();
    final saved = prefs.getString(_keyHeroTheme);
    return saved == 'galaksi' ? 'galaksi' : 'samudra';
  }

  /// Menyimpan tema hero dashboard ('samudra' atau 'galaksi').
  static Future<void> setHeroTheme(String theme) async {
    final normalized = theme == 'galaksi' ? 'galaksi' : 'samudra';
    final prefs = await _getInstance();
    await prefs.setString(_keyHeroTheme, normalized);
  }

  /// Menghapus draft kuis (misal setelah berhasil submit)
  static Future<void> clearQuizDraft(int quizId) async {
    try {
      final prefs = await _getInstance();
      await prefs.remove('$_draftPrefix$quizId');
    } catch (_) {}
  }
}

