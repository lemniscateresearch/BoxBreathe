import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/breathing/breathing_method.dart';
import 'package:box_breathe/breathing/breathing_phase.dart';
import 'package:box_breathe/breathing/breathing_session.dart';
import 'package:box_breathe/common/audio/session_cue.dart';
import 'package:box_breathe/common/session_status.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCuePlayer cues;
  late BreathingSession session;

  setUp(() {
    cues = FakeCuePlayer();
    session = BreathingSession(
      vsync: const TestVSync(),
      cues: cues,
      phaseLength: const Duration(seconds: 1),
    );
  });
  tearDown(() => session.dispose());

  test('starts idle with the default method and length', () {
    expect(session.status, SessionStatus.idle);
    expect(session.method, BreathingMethod.box);
    expect(session.secondsRemaining, 3 * 60);
    expect(session.phase, BreathingPhase.inhale);
    expect(session.canChangeSettings, isTrue);
  });

  test('locks the settings while a session is in progress', () {
    session.startOrResume();
    expect(session.status, SessionStatus.running);

    session.selectMethod(BreathingMethod.triangle);
    session.selectLength(10);
    expect(session.method, BreathingMethod.box);
    expect(session.minutes, 3);

    session.pause();
    expect(session.status, SessionStatus.paused);
    expect(session.canChangeSettings, isFalse);
  });

  test('turns the length into whole breaths', () {
    final fourSecondPhases = BreathingSession(
      vsync: const TestVSync(),
      cues: FakeCuePlayer(),
    );
    addTearDown(fourSecondPhases.dispose);

    // A box breath takes 16 s, so 3 min holds 11 whole breaths (2:56).
    expect(fourSecondPhases.breaths, 11);
    expect(fourSecondPhases.secondsRemaining, 176);
    expect(fourSecondPhases.steps, hasLength(11 * 4));
    expect(fourSecondPhases.steps.last.phase, BreathingPhase.holdAfterExhale);

    // A triangle breath takes 12 s, so 1 min holds 5 breaths exactly.
    fourSecondPhases
      ..selectMethod(BreathingMethod.triangle)
      ..selectLength(1);
    expect(fourSecondPhases.breaths, 5);
    expect(fourSecondPhases.secondsRemaining, 60);
  });

  testWidgets('finishes after the last phase of the last breath', (
    tester,
  ) async {
    // Figure eight has 2 one-second phases, so 1 min is 30 breaths.
    session
      ..selectMethod(BreathingMethod.figureEight)
      ..selectLength(1)
      ..startOrResume();
    expect(session.steps, hasLength(60));

    // Short frames, so each phase that runs out moves on at once.
    await tester.pump();
    while (session.stepIndex < session.steps.length - 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(session.isRunning, isTrue);
    expect(session.step.breath, 30);
    expect(session.phase, BreathingPhase.exhale);
    expect(session.secondsRemaining, 1);

    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(session.isFinished, isTrue);
    expect(session.secondsRemaining, 0);
    expect(cues.cues.last, SessionCue.finished);
  });

  test('reset returns to idle and restores the full length', () {
    session
      ..selectLength(5)
      ..startOrResume()
      ..reset();

    expect(session.status, SessionStatus.idle);
    expect(session.secondsRemaining, 5 * 60);
    expect(session.phaseIndex, 0);
  });

  testWidgets('plays a cue at the start of each phase', (tester) async {
    session.startOrResume();
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 1100));
    }

    expect(cues.cues, [
      SessionCue.breatheIn,
      SessionCue.hold,
      SessionCue.breatheOut,
      SessionCue.hold,
      SessionCue.breatheIn,
    ]);
    expect(cues.words.take(3), ['Breathe in', 'Hold', 'Breathe out']);

    session.reset();
  });

  testWidgets('pause stops the cue, and resume repeats it', (tester) async {
    session.startOrResume();
    await tester.pump();

    final stopsBefore = cues.stops;
    session.pause();
    expect(cues.stops, stopsBefore + 1);

    session.startOrResume();
    expect(cues.cues, [SessionCue.breatheIn, SessionCue.breatheIn]);

    session.reset();
  });
}
