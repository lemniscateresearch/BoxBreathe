import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'cue_player.dart';
import 'session_cue.dart';

/// Says the words of each cue with the platform's text-to-speech engine.
///
/// Cues only help the user, so a text-to-speech failure (for example no
/// engine on the device) is logged and does not stop the session.
class TtsCueSpeaker implements CuePlayer {
  TtsCueSpeaker([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  /// A slightly slower rate is easier to follow while breathing. On
  /// Android and iOS, flutter_tts uses 0.5 for the normal rate. On the
  /// web it passes the rate to the browser, where 1 is normal. Both
  /// values give about 84% of the normal speed.
  static const _speechRate = kIsWeb ? 0.84 : 0.42;

  final FlutterTts _tts;
  Future<void>? _setup;

  @override
  Future<void> play(SessionCue cue, String words) => _guard(() async {
    await (_setup ??= _tts.setSpeechRate(_speechRate));
    await _tts.stop();
    await _tts.speak(words);
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
