import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'cue_speaker.dart';

/// Says cues with the platform's text-to-speech engine.
///
/// Cues only help the user, so a text-to-speech failure (for example no
/// engine on the device) is logged and does not stop the session.
class TtsCueSpeaker implements CueSpeaker {
  TtsCueSpeaker([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  /// flutter_tts uses 0.5 for the normal rate. A slightly slower rate is
  /// easier to follow while breathing.
  static const _speechRate = 0.42;

  final FlutterTts _tts;
  Future<void>? _setup;

  @override
  Future<void> speak(String text) => _guard(() async {
    await (_setup ??= _tts.setSpeechRate(_speechRate));
    await _tts.stop();
    await _tts.speak(text);
  });

  @override
  Future<void> stop() => _guard(() => _tts.stop());

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('Spoken cue failed: $error');
    }
  }
}
