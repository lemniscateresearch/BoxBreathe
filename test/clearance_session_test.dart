import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/clearance/clearance_routine.dart';
import 'package:box_breathe/clearance/clearance_session.dart';
import 'package:box_breathe/clearance/clearance_step.dart';
import 'package:box_breathe/common/audio/session_cue.dart';
import 'package:box_breathe/common/session_status.dart';

import 'fakes.dart';

/// One cycle of one huff, with 1-second timed steps.
const _shortSettings = ClearanceSettings(
  cycles: 1,
  breathingControl: Duration(seconds: 1),
  deepBreaths: 1,
  deepBreathIn: Duration(seconds: 1),
  deepBreathHold: Duration(seconds: 1),
  deepBreathOut: Duration(seconds: 1),
  huffsPerSet: 1,
);

void main() {
  late FakeCuePlayer cues;
  late ClearanceSession session;

  setUp(() {
    cues = FakeCuePlayer();
    session = ClearanceSession(
      vsync: const TestVSync(),
      cues: cues,
      settings: _shortSettings,
    );
  });
  tearDown(() => session.dispose());

  testWidgets('runs timed steps, waits at the huff, then finishes', (
    tester,
  ) async {
    session.selectRoutine(ClearanceRoutine.huffsWithRests);
    session.startOrResume();
    expect(session.step.kind, ClearanceStepKind.breathingControl);

    // The rest runs out and the session stops at the huff.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    expect(session.step.kind, ClearanceStepKind.huff);
    expect(session.isWaitingForHuff, isTrue);

    await tester.pump(const Duration(seconds: 5));
    expect(session.step.kind, ClearanceStepKind.huff);

    // Done moves on to the closing rest, and then the session finishes.
    session.completeHuff();
    expect(session.step.kind, ClearanceStepKind.breathingControl);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    expect(session.status, SessionStatus.finished);

    expect(cues.words, [
      'Relax, and breathe gently',
      'Huff',
      'Relax, and breathe gently',
      'Session complete. Well done.',
    ]);
    expect(cues.cues, [
      SessionCue.rest,
      SessionCue.huff,
      SessionCue.rest,
      SessionCue.finished,
    ]);
  });

  testWidgets('ACBT says each deep breath step in order', (tester) async {
    session.startOrResume();
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 1100));
    }

    expect(cues.words, [
      'Relax, and breathe gently',
      'Breathe in deeply',
      'Hold',
      'Breathe out',
      'Relax, and breathe gently',
      'Huff',
    ]);
    expect(session.isWaitingForHuff, isTrue);
  });

  testWidgets('pause stops the step and the cue, resume repeats the cue', (
    tester,
  ) async {
    session.startOrResume();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    session.pause();
    expect(session.status, SessionStatus.paused);
    expect(cues.stops, 1);

    // While paused, the step does not advance.
    await tester.pump(const Duration(seconds: 5));
    expect(session.stepIndex, 0);

    session.startOrResume();
    expect(session.status, SessionStatus.running);
    expect(cues.words.last, 'Relax, and breathe gently');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(session.step.kind, ClearanceStepKind.deepBreathIn);

    // Stop the running step before the test checks for leftover animations.
    session.reset();
  });

  testWidgets('locks the routine while running and reset unlocks it', (
    tester,
  ) async {
    session.startOrResume();
    session.selectRoutine(ClearanceRoutine.huffsWithRests);
    expect(session.routine, ClearanceRoutine.acbt);

    session.reset();
    expect(session.status, SessionStatus.idle);
    expect(session.stepIndex, 0);

    session.selectRoutine(ClearanceRoutine.huffsWithRests);
    expect(session.routine, ClearanceRoutine.huffsWithRests);
  });
}
