/// The kinds of cue that a session plays when a step starts. Each kind
/// has one tone file in each tone style.
enum SessionCue { breatheIn, hold, breatheOut, huff, rest, finished }

extension SessionCueDetails on SessionCue {
  /// The file name in `assets/sounds/<style>/`. `tool/generate_tones.dart`
  /// uses the same names.
  String get fileName => switch (this) {
    SessionCue.breatheIn => 'breathe_in.wav',
    SessionCue.hold => 'hold.wav',
    SessionCue.breatheOut => 'breathe_out.wav',
    SessionCue.huff => 'huff.wav',
    SessionCue.rest => 'rest.wav',
    SessionCue.finished => 'finished.wav',
  };
}
