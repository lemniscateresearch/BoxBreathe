import 'audio/session_cue.dart';

/// One step that a [StepSession] can run: a breath phase, a huff, a rest
/// between exercises, and so on.
///
/// A step with a [duration] moves on by itself when the time is up. A
/// step without one waits until the user says they are done.
abstract interface class TimedStep {
  /// How long the step lasts, or null if it waits for the user.
  Duration? get duration;

  /// The sound to play when the step begins.
  SessionCue get sessionCue;

  /// A short phrase for the text-to-speech engine.
  String get spokenCue;
}
