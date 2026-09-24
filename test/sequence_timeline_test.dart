import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/breathing/breathing_method.dart';
import 'package:box_breathe/breathing/breathing_phase.dart';
import 'package:box_breathe/clearance/clearance_routine.dart';
import 'package:box_breathe/common/audio/session_cue.dart';
import 'package:box_breathe/sequence/exercise_sequence.dart';
import 'package:box_breathe/sequence/sequence_segment.dart';
import 'package:box_breathe/sequence/sequence_step.dart';
import 'package:box_breathe/sequence/sequence_timeline.dart';

List<SequenceStep> _timeline(List<SequenceSegment> segments) => buildTimeline(
  ExerciseSequence(id: 'a', name: 'Test', segments: segments),
  phaseLength: const Duration(seconds: 4),
  clearance: ClearanceSettings.defaults,
);

void main() {
  test('an empty sequence has no steps', () {
    expect(_timeline([]), isEmpty);
  });

  test('a breathing segment has one step for each phase of each breath', () {
    final steps = _timeline([
      const BreathingSegment(BreathingMethod.triangle, breaths: 2),
    ]);

    expect(steps, hasLength(2 * 3));
    final phases = steps.cast<BreathPhaseStep>();
    expect(phases.map((s) => s.phase), [
      BreathingPhase.inhale,
      BreathingPhase.holdAfterInhale,
      BreathingPhase.exhale,
      BreathingPhase.inhale,
      BreathingPhase.holdAfterInhale,
      BreathingPhase.exhale,
    ]);
    expect(phases.map((s) => s.breath), [1, 1, 1, 2, 2, 2]);
    expect(phases.first.progressLabel, 'Breath 1 of 2');
  });

  test('a clearance segment has the steps of its routine', () {
    final steps = _timeline([
      const ClearanceSegment(ClearanceRoutine.huffsWithRests),
    ]);
    final routineSteps = ClearanceRoutine.huffsWithRests.steps(
      ClearanceSettings.defaults,
    );

    expect(
      steps.cast<ClearanceSequenceStep>().map((s) => s.step.kind),
      routineSteps.map((s) => s.kind),
    );
    expect(steps.where((s) => s.waitsForUser), isNotEmpty);
  });

  test('a transition comes only between two segments', () {
    final steps = _timeline([
      const BreathingSegment(BreathingMethod.figureEight, breaths: 1),
      const ClearanceSegment(ClearanceRoutine.acbt),
      const BreathingSegment(BreathingMethod.box, breaths: 1),
    ]);

    final transitions = steps.whereType<TransitionStep>().toList();
    expect(transitions, hasLength(2));
    expect(steps.first, isA<BreathPhaseStep>());
    expect(steps.last, isA<BreathPhaseStep>());

    // A transition belongs to the segment after it and names it.
    expect(transitions.map((s) => s.segmentIndex), [1, 2]);
    expect(transitions.last.spokenCue, 'Next, Box breathing, 1 breath');
    expect(transitions.last.sessionCue, SessionCue.rest);
  });

  test('the length counts timed steps and mentions huffs', () {
    final breathing = _timeline([
      const BreathingSegment(BreathingMethod.box, breaths: 4),
    ]);
    // 4 breaths × 4 phases × 4 s = 64 s.
    expect(timedLength(breathing), const Duration(seconds: 64));
    expect(lengthLabel(breathing), 'About 2 min');

    final withHuffs = _timeline([
      const ClearanceSegment(ClearanceRoutine.huffsWithRests),
    ]);
    expect(lengthLabel(withHuffs), endsWith(', plus huffs'));
  });
}
