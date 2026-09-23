import 'dart:async';

import '../../settings/app_settings.dart';
import '../../settings/settings_controller.dart';
import 'audio_services.dart';
import 'cue_player.dart';
import 'session_cue.dart';

/// Plays each cue as the settings tell it: as a tone, as spoken words,
/// as both, or not at all. It reads the settings each time, so a change
/// applies to the next cue.
class SettingsCuePlayer implements CuePlayer {
  SettingsCuePlayer({
    required this._settings,
    required this._tones,
    required this._voice,
  });

  final SettingsController _settings;
  final SoundPlayer _tones;
  final CuePlayer _voice;

  /// The asset path of the tone for [cue] in [style].
  static String toneAsset(ToneStyle style, SessionCue cue) =>
      'sounds/${style.folder}/${cue.fileName}';

  @override
  Future<void> play(SessionCue cue, String words) async {
    final settings = _settings.settings;
    await Future.wait([
      if (settings.cueMode.playsTones)
        _tones.play(toneAsset(settings.toneStyle, cue), settings.cueVolume),
      if (settings.cueMode.speaks) _voice.play(cue, words),
    ]);
  }

  @override
  Future<void> stop() async {
    await Future.wait([_tones.stop(), _voice.stop()]);
  }

  Future<void> dispose() async {
    await stop();
    await _tones.dispose();
  }
}
