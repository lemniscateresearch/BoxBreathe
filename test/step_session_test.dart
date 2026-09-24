import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/common/audio/session_cue.dart';
import 'package:box_breathe/common/session_status.dart';
import 'package:box_breathe/common/step_session.dart';
import 'package:box_breathe/common/timed_step.dart';

import 'fakes.dart';

class _FakeStep implements TimedStep {
  /// A step that lasts one second.
  const _FakeStep(this.spokenCue)
    : duration = const Duration(seconds: 1),
      sessionCue = SessionCue.rest;

  /// A step that waits for the user.
  const _FakeStep.waits(this.spokenCue)
    : duration = null,
      sessionCue = SessionCue.huff;

  @override
  final Duration? duration;
  @override
  final SessionCue sessionCue;
  @override
  final String spokenCue;
}

class _TestSession extends StepSession<_FakeStep> {
  _TestSession(FakeCuePlayer cues)
    : super(vsync: const TestVSync(), cues: cues, finishedCue: 'Finished');

  void select(List<_FakeStep> steps) => replaceSteps(steps);
}

const _a = _FakeStep('A');
const _b = _FakeStep('B');
const _huff = _FakeStep.waits('Huff');

void main() {
  late FakeCuePlayer cues;
  late _TestSession session;

  setUp(() {
    cues = FakeCuePlayer();
    session = _TestSession(cues);
  });
  tearDown(() => session.dispose());

  /// Pumps in short frames, so each step that runs out moves on.
  Future<void> wait(WidgetTester tester, Duration duration) async {
    await tester.pump();
    for (var t = Duration.zero; t < duration; t += _frame) {
      await tester.pump(_frame);
    }
  }

  test('is idle, with no steps, at first', () {
    expect(session.status, SessionStatus.idle);
    expect(session.steps, isEmpty);
    expect(session.step, isNull);
    expect(session.canStart, isFalse);
    expect(session.canChangeSettings, isTrue);
  });

  test('does not start without steps', () {
    session.startOrResume();
    expect(session.status, SessionStatus.idle);
    expect(cues.words, isEmpty);
  });

  testWidgets('runs timed steps in order, then finishes', (tester) async {
    session
      ..select([_a, _b])
      ..startOrResume();
    expect(session.status, SessionStatus.running);
    expect(session.step, _a);
    expect(session.canChangeSettings, isFalse);

    await wait(tester, const Duration(milliseconds: 1100));
    expect(session.step, _b);
    expect(session.stepIndex, 1);

    await wait(tester, const Duration(milliseconds: 1100));
    expect(session.status, SessionStatus.finished);
    expect(session.isFinished, isTrue);
    expect(session.canChangeSettings, isTrue);

    expect(cues.words, ['A', 'B', 'Finished']);
    expect(cues.cues, [SessionCue.rest, SessionCue.rest, SessionCue.finished]);
  });

  testWidgets('stepProgress goes from 0 to 1 during a timed step', (
    tester,
  ) async {
    session
      ..select([_a, _b])
      ..startOrResume();
    expect(session.stepProgress.value, 0);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(session.stepProgress.value, closeTo(0.5, 0.05));
    session.reset();
  });

  testWidgets('waits at a step without a duration until completeStep', (
    tester,
  ) async {
    session
      ..select([_huff, _a])
      ..startOrResume();
    expect(session.isWaitingForUser, isTrue);

    await wait(tester, const Duration(seconds: 5));
    expect(session.step, _huff);
    expect(session.stepProgress.value, 0);

    session.completeStep();
    expect(session.step, _a);
    expect(session.isWaitingForUser, isFalse);
    expect(cues.words, ['Huff', 'A']);
  });

  testWidgets('completeStep does nothing at a timed step', (tester) async {
    session
      ..select([_a, _b])
      ..startOrResume()
      ..completeStep();
    expect(session.step, _a);
    session.reset();
  });

  testWidgets('completeStep does nothing while paused', (tester) async {
    session
      ..select([_huff, _a])
      ..startOrResume()
      ..pause();
    expect(session.isWaitingForUser, isFalse);

    session.completeStep();
    expect(session.step, _huff);
  });

  testWidgets('pause holds the step, and resume goes on from there', (
    tester,
  ) async {
    session
      ..select([_a, _b])
      ..startOrResume();
    await wait(tester, const Duration(milliseconds: 500));

    final stopsBefore = cues.stops;
    session.pause();
    expect(session.status, SessionStatus.paused);
    expect(cues.stops, stopsBefore + 1);

    final progress = session.stepProgress.value;
    await wait(tester, const Duration(seconds: 3));
    expect(session.step, _a);
    expect(session.stepProgress.value, progress);

    // Resume plays the cue of the current step again, and the step ends
    // after the time that was left.
    session.startOrResume();
    expect(session.status, SessionStatus.running);
    expect(cues.words, ['A', 'A']);
    await wait(tester, const Duration(milliseconds: 600));
    expect(session.step, _b);
    session.reset();
  });

  testWidgets('pause does nothing unless the session runs', (tester) async {
    session.select([_a]);
    final stopsBefore = cues.stops;
    session.pause();
    expect(session.status, SessionStatus.idle);
    expect(cues.stops, stopsBefore);
  });

  testWidgets('reset goes back to the first step, idle', (tester) async {
    session
      ..select([_a, _b])
      ..startOrResume();
    await wait(tester, const Duration(milliseconds: 1100));
    expect(session.step, _b);

    final stopsBefore = cues.stops;
    session.reset();
    expect(session.status, SessionStatus.idle);
    expect(session.step, _a);
    expect(session.stepProgress.value, 0);
    expect(cues.stops, stopsBefore + 1);
  });

  testWidgets('start again after the finish begins at the first step', (
    tester,
  ) async {
    session
      ..select([_a, _b])
      ..startOrResume();
    await wait(tester, const Duration(milliseconds: 2200));
    expect(session.isFinished, isTrue);

    session.startOrResume();
    expect(session.status, SessionStatus.running);
    expect(session.step, _a);
    expect(cues.words.last, 'A');
    session.reset();
  });

  testWidgets('replaceSteps is refused while a session is in progress', (
    tester,
  ) async {
    session
      ..select([_a, _b])
      ..startOrResume()
      ..select([_huff]);
    expect(session.steps, [_a, _b]);

    session
      ..pause()
      ..select([_huff]);
    expect(session.steps, [_a, _b]);
    session.reset();
  });

  testWidgets('replaceSteps works when finished, and resets', (tester) async {
    session
      ..select([_a])
      ..startOrResume();
    await wait(tester, const Duration(milliseconds: 1100));
    expect(session.isFinished, isTrue);

    session.select([_huff, _b]);
    expect(session.steps, [_huff, _b]);
    expect(session.status, SessionStatus.idle);
    expect(session.stepIndex, 0);
  });

  testWidgets('notifies listeners on each change', (tester) async {
    var notified = 0;
    session
      ..addListener(() => notified++)
      ..select([_a, _huff]);
    expect(notified, 1);

    session.startOrResume();
    expect(notified, 2);

    await wait(tester, const Duration(milliseconds: 1100));
    expect(notified, 3); // Moved on to the huff.

    session.pause();
    expect(notified, 4);
    session.startOrResume();
    expect(notified, 5);
    session.completeStep();
    expect(notified, 6); // Finished.
  });
}

const _frame = Duration(milliseconds: 100);
