import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/breathing/breathing_method.dart';
import 'package:box_breathe/clearance/clearance_routine.dart';
import 'package:box_breathe/common/audio/session_cue.dart';
import 'package:box_breathe/common/session_status.dart';
import 'package:box_breathe/sequence/exercise_sequence.dart';
import 'package:box_breathe/sequence/sequence_segment.dart';
import 'package:box_breathe/sequence/sequence_session.dart';
import 'package:box_breathe/sequence/sequence_step.dart';

import 'fakes.dart';

/// One cycle of one huff, with 1-second timed steps.
const _shortClearance = ClearanceSettings(
  cycles: 1,
  breathingControl: Duration(seconds: 1),
  deepBreaths: 1,
  deepBreathIn: Duration(seconds: 1),
  deepBreathHold: Duration(seconds: 1),
  deepBreathOut: Duration(seconds: 1),
  huffsPerSet: 1,
);

/// One figure-eight breath, then huffs with rests.
const _sequence = ExerciseSequence(
  id: 'a',
  name: 'Test',
  segments: [
    BreathingSegment(BreathingMethod.figureEight, breaths: 1),
    ClearanceSegment(ClearanceRoutine.huffsWithRests),
  ],
);

void main() {
  late FakeCuePlayer cues;
  late SequenceSession session;

  setUp(() {
    cues = FakeCuePlayer();
    session = SequenceSession(
      vsync: const TestVSync(),
      cues: cues,
      phaseLength: const Duration(seconds: 1),
      clearance: _shortClearance,
    );
  });
  tearDown(() => session.dispose());

  /// Lets one 1-second step run out.
  Future<void> nextStep(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
  }

  test('cannot start without a sequence or without parts', () {
    session.startOrResume();
    expect(session.status, SessionStatus.idle);

    session.selectSequence(const ExerciseSequence(id: 'b', name: 'Empty'));
    expect(session.canStart, isFalse);
    session.startOrResume();
    expect(session.status, SessionStatus.idle);
    expect(session.step, isNull);
  });

  testWidgets('runs each part in order, waits at the huff, then finishes', (
    tester,
  ) async {
    session
      ..selectSequence(_sequence)
      ..startOrResume();
    expect(session.step, isA<BreathPhaseStep>());

    await nextStep(tester); // Breathe in → breathe out.
    await nextStep(tester); // Breathe out → transition.
    expect(session.step, isA<TransitionStep>());
    expect(session.step!.segmentIndex, 1);

    // The transition lasts 5 seconds, then the first rest starts.
    await tester.pump();
    await tester.pump(
      TransitionStep.length + const Duration(milliseconds: 100),
    );
    expect(session.step, isA<ClearanceSequenceStep>());

    await nextStep(tester); // Rest → huff.
    expect(session.isWaitingForUser, isTrue);
    await tester.pump(const Duration(seconds: 5));
    expect(session.isWaitingForUser, isTrue);

    session.completeStep();
    await nextStep(tester); // Closing rest → finished.
    expect(session.status, SessionStatus.finished);

    expect(cues.cues, [
      SessionCue.breatheIn,
      SessionCue.breatheOut,
      SessionCue.rest,
      SessionCue.rest,
      SessionCue.huff,
      SessionCue.rest,
      SessionCue.finished,
    ]);
    expect(cues.words[2], 'Next, Huffs with rests');
  });

  testWidgets('locks the sequence while a session is in progress', (
    tester,
  ) async {
    session
      ..selectSequence(_sequence)
      ..startOrResume();
    session.selectSequence(null);
    expect(session.sequence, _sequence);

    session.pause();
    expect(session.canChangeSettings, isFalse);
    expect(cues.stops, greaterThan(0));

    session.startOrResume();
    expect(session.status, SessionStatus.running);
    expect(cues.cues, [SessionCue.breatheIn, SessionCue.breatheIn]);

    session.reset();
    expect(session.status, SessionStatus.idle);
    expect(session.stepIndex, 0);
  });
}
