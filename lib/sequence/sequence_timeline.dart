import '../breathing/breathing_method.dart';
import '../clearance/clearance_routine.dart';
import 'exercise_sequence.dart';
import 'sequence_segment.dart';
import 'sequence_step.dart';

/// Expands [sequence] into the steps of a full session. Each breath of
/// a breathing shape gives one step for each phase, with [phaseLength]
/// for each. Each clearance routine gives its steps for [clearance]. A
/// transition comes between two segments.
List<SequenceStep> buildTimeline(
  ExerciseSequence sequence, {
  required Duration phaseLength,
  required ClearanceSettings clearance,
}) => [
  for (final (index, segment) in sequence.segments.indexed) ...[
    if (index > 0) TransitionStep(segmentIndex: index, next: segment),
    ...switch (segment) {
      BreathingSegment(:final method, :final breaths) => [
        for (var breath = 1; breath <= breaths; breath++)
          for (var phase = 0; phase < method.phases.length; phase++)
            BreathPhaseStep(
              segmentIndex: index,
              method: method,
              phaseIndex: phase,
              breath: breath,
              breaths: breaths,
              duration: phaseLength,
            ),
      ],
      ClearanceSegment(:final routine) => [
        for (final step in routine.steps(clearance))
          ClearanceSequenceStep(
            segmentIndex: index,
            step: step,
            cycles: clearance.cycles,
          ),
      ],
    },
  ],
];

/// The total length of the timed steps. Steps that wait for the user,
/// such as huffs, are not included, so the real session takes longer.
Duration timedLength(List<SequenceStep> steps) => steps.fold(
  Duration.zero,
  (total, step) => total + (step.duration ?? Duration.zero),
);

/// The length of [steps] in words, for example "About 7 min, plus huffs".
String lengthLabel(List<SequenceStep> steps) {
  final minutes = (timedLength(steps).inSeconds / 60).ceil().clamp(1, 999);
  final waits = steps.any((step) => step.waitsForUser);
  return 'About $minutes min${waits ? ', plus huffs' : ''}';
}
