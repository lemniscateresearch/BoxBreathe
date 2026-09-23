import 'package:flutter/foundation.dart';

import 'package:box_breathe/common/audio/audio_services.dart';
import 'package:box_breathe/common/audio/cue_player.dart';
import 'package:box_breathe/common/audio/session_cue.dart';
import 'package:box_breathe/common/guided_session.dart';
import 'package:box_breathe/common/session_status.dart';

/// Records the cues that a session plays.
class FakeCuePlayer implements CuePlayer {
  final cues = <SessionCue>[];
  final words = <String>[];
  var stops = 0;

  @override
  Future<void> play(SessionCue cue, String words) async {
    cues.add(cue);
    this.words.add(words);
  }

  @override
  Future<void> stop() async => stops++;
}

/// Records the calls to a sound or music player, as text.
class FakeSoundPlayer implements SoundPlayer {
  final calls = <String>[];

  @override
  Future<void> play(String assetPath, double volume) async =>
      calls.add('play $assetPath $volume');

  @override
  Future<void> stop() async => calls.add('stop');

  @override
  Future<void> dispose() async => calls.add('dispose');
}

class FakeMusicPlayer implements MusicPlayer {
  final calls = <String>[];

  @override
  Future<void> start(String assetPath, double volume) async =>
      calls.add('start $assetPath $volume');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> fadeOutAndStop() async => calls.add('fadeOut');

  @override
  Future<void> dispose() async => calls.add('dispose');
}

/// A session whose status a test sets directly.
class FakeSession extends ChangeNotifier implements GuidedSession {
  SessionStatus _status = SessionStatus.idle;

  @override
  SessionStatus get status => _status;

  set status(SessionStatus status) {
    _status = status;
    notifyListeners();
  }
}
