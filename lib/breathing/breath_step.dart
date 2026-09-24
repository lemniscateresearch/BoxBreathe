import '../common/audio/session_cue.dart';
import '../common/timed_step.dart';
import 'breathing_method.dart';
import 'breathing_phase.dart';

/// One phase of one breath in a breathing session.
class BreathStep implements TimedStep {
  const BreathStep({
    required this.method,
    required this.phaseIndex,
    required this.breath,
    required this.breaths,
    required this.duration,
  });

  final BreathingMethod method;

  /// The position of [phase] in the method's phases.
  final int phaseIndex;

  /// Which breath this is, starting at 1, out of [breaths].
  final int breath;
  final int breaths;

  @override
  final Duration duration;

  BreathingPhase get phase => method.phases[phaseIndex];

  @override
  SessionCue get sessionCue => phase.sessionCue;

  @override
  String get spokenCue => phase.title;
}
