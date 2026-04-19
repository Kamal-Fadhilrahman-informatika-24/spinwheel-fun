// ============================================================
// services/audio_service.dart
// Sound effect saat spin menggunakan audioplayers
// File audio: assets/sounds/spin.mp3, win.mp3
// Kalau tidak punya file, bisa pakai AudioCache dari URL
// ============================================================

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final AudioPlayer _spinPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();

  bool soundEnabled = true;

  // ── Suara saat roda mulai berputar ────────────────────────────
  Future<void> playSpin() async {
    if (!soundEnabled) return;
    try {
      // Coba dari asset lokal dulu; kalau tidak ada, skip
      await _spinPlayer.play(AssetSource('sounds/spin.mp3'));
    } catch (_) {
      // File tidak ditemukan — tidak apa-apa
    }
  }

  // ── Suara saat hasil keluar ───────────────────────────────────
  Future<void> playWin() async {
    if (!soundEnabled) return;
    try {
      await _winPlayer.play(AssetSource('sounds/win.mp3'));
    } catch (_) {}
  }

  // ── Stop semua ────────────────────────────────────────────────
  Future<void> stopAll() async {
    await _spinPlayer.stop();
    await _winPlayer.stop();
  }

  void dispose() {
    _spinPlayer.dispose();
    _winPlayer.dispose();
  }
}
