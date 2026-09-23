import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/breathing/breathing_method.dart';
import 'package:box_breathe/breathing/breathing_phase.dart';
import 'package:box_breathe/breathing/breathing_session.dart';
import 'package:box_breathe/common/session_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BreathingSession session;

  setUp(() => session = BreathingSession(vsync: const TestVSync()));
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
}
