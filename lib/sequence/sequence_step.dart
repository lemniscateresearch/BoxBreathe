import '../breathing/breathing_method.dart';
import '../breathing/breathing_phase.dart';
import '../clearance/clearance_step.dart';
import '../common/audio/session_cue.dart';
import 'sequence_segment.dart';

/// One step of a sequence session. `buildTimeline` expands a sequence
/// into a list of steps, and the session plays them in order.
sealed class SequenceStep {
  const SequenceStep({required this.segmentIndex});

  /// The segment that this step belongs to, starting at 0. A transition
  /// belongs to the segment that comes after it.
  final int segmentIndex;

  /// How long the step lasts. A step without a duration waits until the
  /// user says that they are done.
  Duration? get duration;

  bool get waitsForUser => duration == null;

  String get title;
  String get cue;

  /// A short phrase for the text-to-speech engine.
  String get spokenCue;
  SessionCue get sessionCue;

  /// Where the step is inside its segment, for example "Breath 2 of 6".
  String get progressLabel;
}

/// One phase of one breath of a breathing shape.
final class BreathPhaseStep extends SequenceStep {
  const BreathPhaseStep({
    required super.segmentIndex,
    required this.method,
    required this.phaseIndex,
    required this.breath,
    required this.breaths,
    required this.duration,
  });

  final BreathingMethod method;
  final int phaseIndex;

  /// Which breath this is, starting at 1, out of [breaths].
  final int breath;
  final int breaths;

  @override
  final Duration duration;

  BreathingPhase get phase => method.phases[phaseIndex];

  @override
  String get title => phase.title;
  @override
  String get cue => phase.cue;
  @override
  String get spokenCue => phase.title;
  @override
  SessionCue get sessionCue => phase.sessionCue;
  @override
  String get progressLabel => 'Breath $breath of $breaths';
}

/// One step of an airway clearance routine.
final class ClearanceSequenceStep extends SequenceStep {
  const ClearanceSequenceStep({
    required super.segmentIndex,
    required this.step,
    required this.cycles,
  });

  final ClearanceStep step;

  /// The number of cycles in the routine, for the progress label.
  final int cycles;

  @override
  Duration? get duration => step.duration;
  @override
  String get title => step.kind.title;
  @override
  String get cue => step.kind.cue;
  @override
  String get spokenCue => step.kind.spokenCue;
  @override
  SessionCue get sessionCue => step.kind.sessionCue;
  @override
  String get progressLabel => step.progressLabel(cycles);
}

/// A short rest before the next segment, which tells the user what
/// comes next.
final class TransitionStep extends SequenceStep {
  const TransitionStep({required super.segmentIndex, required this.next});

  static const length = Duration(seconds: 5);

  final SequenceSegment next;

  String get _nextName => switch (next) {
    BreathingSegment(:final breaths) =>
      '${next.title}, $breaths ${breaths == 1 ? 'breath' : 'breaths'}',
    ClearanceSegment() => next.title,
  };

  @override
  Duration get duration => length;
  @override
  String get title => 'Get ready';
  @override
  String get cue => 'Next: $_nextName.';
  @override
  String get spokenCue => 'Next, $_nextName';
  @override
  SessionCue get sessionCue => SessionCue.rest;
  @override
  String get progressLabel => 'Up next';
}
