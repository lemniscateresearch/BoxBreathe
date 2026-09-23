import 'package:flutter/painting.dart';

import '../common/audio/session_cue.dart';

enum ClearanceStepKind {
  breathingControl,
  deepBreathIn,
  deepBreathHold,
  deepBreathOut,
  huff,
}

extension ClearanceStepKindDetails on ClearanceStepKind {
  String get title => switch (this) {
    ClearanceStepKind.breathingControl => 'Relaxed breathing',
    ClearanceStepKind.deepBreathIn => 'Breathe in deeply',
    ClearanceStepKind.deepBreathHold => 'Hold',
    ClearanceStepKind.deepBreathOut => 'Breathe out',
    ClearanceStepKind.huff => 'Huff',
  };

  String get cue => switch (this) {
    ClearanceStepKind.breathingControl =>
      'Breathe gently through your nose. Let your shoulders relax.',
    ClearanceStepKind.deepBreathIn => 'Take a slow, deep breath in.',
    ClearanceStepKind.deepBreathHold => 'Hold the breath gently.',
    ClearanceStepKind.deepBreathOut => 'Let the breath out slowly and gently.',
    ClearanceStepKind.huff =>
      'Take a medium breath in, then breathe out hard through an open '
          'mouth, as if you are fogging up a mirror. Cough if you need to, '
          'then tap Done.',
  };

  /// A short phrase for the text-to-speech engine.
  String get spokenCue => switch (this) {
    ClearanceStepKind.breathingControl => 'Relax, and breathe gently',
    ClearanceStepKind.deepBreathIn => 'Breathe in deeply',
    ClearanceStepKind.deepBreathHold => 'Hold',
    ClearanceStepKind.deepBreathOut => 'Breathe out',
    ClearanceStepKind.huff => 'Huff',
  };

  SessionCue get sessionCue => switch (this) {
    ClearanceStepKind.breathingControl => SessionCue.rest,
    ClearanceStepKind.deepBreathIn => SessionCue.breatheIn,
    ClearanceStepKind.deepBreathHold => SessionCue.hold,
    ClearanceStepKind.deepBreathOut => SessionCue.breatheOut,
    ClearanceStepKind.huff => SessionCue.huff,
  };

  Color get color => switch (this) {
    ClearanceStepKind.breathingControl => const Color(0xFF5974A4),
    ClearanceStepKind.deepBreathIn => const Color(0xFF398F7B),
    ClearanceStepKind.deepBreathHold => const Color(0xFF246457),
    ClearanceStepKind.deepBreathOut => const Color(0xFF6B8DC4),
    ClearanceStepKind.huff => const Color(0xFFC0773B),
  };
}

/// One step of an airway clearance routine.
class ClearanceStep {
  const ClearanceStep({
    required this.kind,
    required this.duration,
    required this.cycle,
    this.repetition = 1,
    this.repetitions = 1,
  });

  final ClearanceStepKind kind;

  /// How long the step lasts. A step without a duration waits until the
  /// user says that they are done.
  final Duration? duration;

  /// The cycle that contains this step, starting at 1.
  final int cycle;

  /// For a deep breath or a huff: which one this is, starting at 1, out
  /// of [repetitions].
  final int repetition;
  final int repetitions;

  bool get waitsForUser => duration == null;
}
