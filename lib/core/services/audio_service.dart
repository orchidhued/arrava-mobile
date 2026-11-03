import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../storage/preferences_service.dart';

class AudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static bool? _soundCached;
  static bool? _hapticCached;

  /// Memperbarui cache preferensi audio di memori untuk performa instan tanpa lag
  static Future<void> syncPreferences() async {
    _soundCached = await PreferencesService.isSoundEnabled();
    _hapticCached = await PreferencesService.isHapticEnabled();
  }

  /// Memainkan efek suara ketika siswa memilih pilihan jawaban kuis
  static Future<void> playTapSound() async {
    await _playAsset('sounds/widgets/buttonWorkingSound.mp3');
  }

  /// Memainkan efek suara klik menu atau navigasi
  static Future<void> playMenuClickSound() async {
    await _playAsset('sounds/widgets/menuClickSound.mp3');
  }

  /// Memainkan efek suara ketika jawaban salah atau waktu habis
  static Future<void> playErrorSound() async {
    await _playAsset('sounds/widgets/errorSound.mp3');
  }

  /// Memainkan efek jingle kemenangan / kuis selesai
  static Future<void> playCompletionSound() async {
    await _playAsset('sounds/widgets/jingleSnowSound.wav');
  }

  /// Memberikan getaran haptic feedback pada perangkat
  static Future<void> triggerHaptic() async {
    _hapticCached ??= await PreferencesService.isHapticEnabled();
    if (_hapticCached == true) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  /// Helper internal untuk memainkan file asset sound jika sound diaktifkan
  static Future<void> _playAsset(String relativePath) async {
    _soundCached ??= await PreferencesService.isSoundEnabled();
    if (_soundCached != true) return;

    try {
      // Hentikan suara sebelumnya sebelum memainkan suara baru agar tidak tumpang tindih
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(relativePath));
    } catch (_) {}
  }

  /// Membersihkan resource audio player
  static void dispose() {
    try {
      _sfxPlayer.dispose();
    } catch (_) {}
  }
}
