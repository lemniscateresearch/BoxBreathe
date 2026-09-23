import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/clearance/clearance_routine.dart';
import 'package:box_breathe/clearance/clearance_step.dart';

void main() {
  const settings = ClearanceSettings.defaults;

  test('ACBT cycle: rest, deep breaths, rest, huffs with a rest between', () {
    final steps = ClearanceRoutine.acbt.steps(settings);
    final firstCycle = steps
        .where((step) => step.cycle == 1)
        .map((step) => step.kind)
        .toList();

    expect(firstCycle, [
      ClearanceStepKind.breathingControl,
      for (var i = 0; i < 3; i++) ...[
        ClearanceStepKind.deepBreathIn,
        ClearanceStepKind.deepBreathHold,
        ClearanceStepKind.deepBreathOut,
      ],
      ClearanceStepKind.breathingControl,
      ClearanceStepKind.huff,
      ClearanceStepKind.breathingControl,
      ClearanceStepKind.huff,
    ]);
    // 14 steps in each of 3 cycles, and a closing rest.
    expect(steps, hasLength(14 * 3 + 1));
    expect(steps.last.kind, ClearanceStepKind.breathingControl);
  });

  test('huffs with rests leaves out the deep breaths', () {
    final steps = ClearanceRoutine.huffsWithRests.steps(settings);

    expect(steps.map((step) => step.kind), [
      for (var cycle = 0; cycle < 3; cycle++) ...[
        ClearanceStepKind.breathingControl,
        ClearanceStepKind.huff,
        ClearanceStepKind.breathingControl,
        ClearanceStepKind.huff,
      ],
      ClearanceStepKind.breathingControl,
    ]);
  });

  test('only huff steps wait for the user', () {
    for (final routine in ClearanceRoutine.values) {
      for (final step in routine.steps(settings)) {
        expect(
          step.waitsForUser,
          step.kind == ClearanceStepKind.huff,
          reason: '${step.kind} in $routine',
        );
      }
    }
  });

  test('numbers the huffs within each set', () {
    final huffs = ClearanceRoutine.huffsWithRests
        .steps(settings)
        .where((step) => step.kind == ClearanceStepKind.huff)
        .map((step) => (step.cycle, step.repetition, step.repetitions));

    expect(huffs, [
      (1, 1, 2),
      (1, 2, 2),
      (2, 1, 2),
      (2, 2, 2),
      (3, 1, 2),
      (3, 2, 2),
    ]);
  });
}
