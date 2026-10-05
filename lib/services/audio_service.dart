import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> currentPlayingTitleNotifier = ValueNotifier<String?>(null);

  void _init() {
    _player.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      isPlayingNotifier.value = playing;
      if (!playing) {
        currentPlayingTitleNotifier.value = null;
      }
    });
  }

  Future<void> playSoundType(String type, {String? customTitle}) async {
    await stop();
    String assetPath;
    String title;

    switch (type) {
      case 'sabah':
        assetPath = 'audio/ezan_sabah.mp3';
        title = customTitle ?? 'Sabah Ezanı';
        break;
      case 'chime':
        assetPath = 'audio/chime.wav';
        title = customTitle ?? 'Uyarı Melodisi';
        break;
      case 'mekke':
      default:
        assetPath = 'audio/ezan_mekke.mp3';
        title = customTitle ?? 'Mekke-i Mükerreme Ezanı';
        break;
    }

    try {
      currentPlayingTitleNotifier.value = title;
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Audio play error: $e');
      isPlayingNotifier.value = false;
      currentPlayingTitleNotifier.value = null;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
    isPlayingNotifier.value = false;
    currentPlayingTitleNotifier.value = null;
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  void dispose() {
    _player.dispose();
  }
}
