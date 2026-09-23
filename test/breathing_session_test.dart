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

    session.pause();
    expect(cues.stops, 1);

    session.startOrResume();
    expect(cues.cues, [SessionCue.breatheIn, SessionCue.breatheIn]);

    session.reset();
  });
}
