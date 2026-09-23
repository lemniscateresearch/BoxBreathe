import 'dart:async';

import '../guided_session.dart';
import '../session_status.dart';
import 'audio_services.dart';
import 'music_track.dart';

/// Plays music while a session runs. The music pauses when the session
/// pauses, and fades out when the session ends or is reset.
class SessionMusic {
  /// When [track] is null, the music is off and this object does nothing.
  SessionMusic({
    required this._session,
    required this._player,
    required this._track,
    required this._volume,
  }) {
    _status = _session.status;
    _session.addListener(_onSessionChanged);
  }

  final GuidedSession _session;
  final MusicPlayer _player;
  final MusicTrack? _track;
  final double _volume;

  late SessionStatus _status;
  bool _isPlaying = false;

  void _onSessionChanged() {
    final track = _track;
    final status = _session.status;
    if (track == null || status == _status) return;
    _status = status;

    switch (status) {
      case SessionStatus.running:
        unawaited(
          _isPlaying
              ? _player.resume()
              : _player.start(track.assetPath, _volume),
        );
        _isPlaying = true;
      case SessionStatus.paused:
        unawaited(_player.pause());
      case SessionStatus.idle || SessionStatus.finished:
        if (_isPlaying) unawaited(_player.fadeOutAndStop());
        _isPlaying = false;
    }
  }

  Future<void> dispose() async {
    _session.removeListener(_onSessionChanged);
    await _player.dispose();
  }
}
