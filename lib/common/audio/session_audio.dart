import 'package:flutter/widgets.dart';

import '../../settings/app_settings.dart';
import '../../settings/settings_scope.dart';
import '../guided_session.dart';
import 'audio_scope.dart';
import 'audio_services.dart';
import 'cue_player.dart';
import 'session_music.dart';
import 'settings_cue_player.dart';

/// The cue player and the music of one session page, made from the
/// current settings.
class SessionAudio {
  /// Reads the settings and the audio services from [context]. Call this
  /// in `initState`.
  factory SessionAudio.of(BuildContext context) {
    final settings = SettingsScope.read(context);
    final services = AudioScope.of(context);
    return SessionAudio._(
      services,
      settings.settings,
      SettingsCuePlayer(
        settings: settings,
        tones: services.createSoundPlayer(),
        voice: services.createVoice(),
      ),
    );
  }

  SessionAudio._(this._services, this._settings, this._cues);

  final AudioServices _services;

  /// The settings when the page opened. The music uses them for the
  /// whole visit.
  final AppSettings _settings;
  final SettingsCuePlayer _cues;
  SessionMusic? _music;

  CuePlayer get cues => _cues;

  /// Plays the selected music while [session] runs, if music is on.
  void playMusicDuring(GuidedSession session) {
    _music = SessionMusic(
      session: session,
      player: _services.createMusicPlayer(),
      track: _settings.musicEnabled ? _settings.musicTrack : null,
      volume: _settings.musicVolume,
    );
  }

  Future<void> dispose() async {
    await _music?.dispose();
    await _cues.dispose();
  }
}
