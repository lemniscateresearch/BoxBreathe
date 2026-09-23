import 'session_cue.dart';

/// Tells the user that a new step starts, so that they can follow a
/// session without looking at the screen.
abstract interface class CuePlayer {
  /// Plays [cue]. A player that speaks says [words]. A cue that is still
  /// playing stops first.
  Future<void> play(SessionCue cue, String words);

  /// Stops the cue that is playing, if there is one.
  Future<void> stop();
}

/// A player that plays nothing.
class SilentCuePlayer implements CuePlayer {
  const SilentCuePlayer();

  @override
  Future<void> play(SessionCue cue, String words) async {}

  @override
  Future<void> stop() async {}
}
