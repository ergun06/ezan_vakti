import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  TtsService._internal() {
    _init();
  }

  final FlutterTts _flutterTts = FlutterTts();
  final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier<bool>(false);
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('tr-TR');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5); // Clear, easily understandable speed
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        isSpeakingNotifier.value = true;
      });

      _flutterTts.setCompletionHandler(() {
        isSpeakingNotifier.value = false;
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        isSpeakingNotifier.value = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Init error: $e');
    }
  }

  Future<void> speak(String text) async {
    await stop();
    await _init();
    try {
      isSpeakingNotifier.value = true;
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
      isSpeakingNotifier.value = false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
    isSpeakingNotifier.value = false;
  }
}
