import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../common/audio/cue_player.dart';
import '../common/audio/session_cue.dart';
import '../common/guided_session.dart';
import '../common/session_status.dart';
import 'clearance_routine.dart';
import 'clearance_step.dart';

/// Holds the state of one airway clearance session: the selected
/// routine, the current step, and the progress through that step.
///
/// Timed steps advance on their own. A huff step waits until the user
/// calls [completeHuff], because a huff and a cough take a different
/// length of time for each person.
class ClearanceSession extends ChangeNotifier implements GuidedSession {
  ClearanceSession({
    required TickerProvider vsync,
    required this._cues,
    this.settings = ClearanceSettings.defaults,
  }) {
    _stepAnimation = AnimationController(vsync: vsync)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && isRunning) _advance();
      });
    _steps = _routine.steps(settings);
  }

  static const _finishedCue = 'Session complete. Well done.';

  final ClearanceSettings settings;
  final CuePlayer _cues;
  late final AnimationController _stepAnimation;

  ClearanceRoutine _routine = ClearanceRoutine.acbt;
  late List<ClearanceStep> _steps;
  int _stepIndex = 0;
  SessionStatus _status = SessionStatus.idle;

  ClearanceRoutine get routine => _routine;
  List<ClearanceStep> get steps => _steps;
  int get stepIndex => _stepIndex;
  ClearanceStep get step => _steps[_stepIndex];
  @override
  SessionStatus get status => _status;

  /// Goes from 0 to 1 during each timed step. It stays at 0 during a huff.
  Animation<double> get stepProgress => _stepAnimation;

  bool get isRunning => _status == SessionStatus.running;
  bool get isFinished => _status == SessionStatus.finished;
  bool get isWaitingForHuff => isRunning && step.waitsForUser;

  /// The user can change the routine only when no session is in progress.
  bool get canChangeSettings =>
      _status == SessionStatus.idle || _status == SessionStatus.finished;

  void startOrResume() {
    final isResuming = _status == SessionStatus.paused;
    if (isFinished) _stepIndex = 0;
    _status = SessionStatus.running;

    if (isResuming) {
      if (!step.waitsForUser) _stepAnimation.forward();
      _playStepCue();
      notifyListeners();
    } else {
      _beginStep();
    }
  }

  void pause() {
    if (!isRunning) return;
    _status = SessionStatus.paused;
    _stepAnimation.stop();
    unawaited(_cues.stop());
    notifyListeners();
  }

  void reset() {
    _stepAnimation.reset();
    _stepIndex = 0;
    _status = SessionStatus.idle;
    unawaited(_cues.stop());
    notifyListeners();
  }

  void selectRoutine(ClearanceRoutine routine) {
    if (!canChangeSettings) return;
    _routine = routine;
    _steps = routine.steps(settings);
    reset();
  }

  /// Moves on from a huff step when the user taps Done.
  void completeHuff() {
    if (isWaitingForHuff) _advance();
  }

  void _beginStep() {
    _stepAnimation.reset();
    final duration = step.duration;
    if (duration != null) {
      _stepAnimation
        ..duration = duration
        ..forward();
    }
    _playStepCue();
    notifyListeners();
  }

  void _advance() {
    if (_stepIndex == _steps.length - 1) {
      _finish();
    } else {
      _stepIndex++;
      _beginStep();
    }
  }

  void _finish() {
    _stepAnimation.stop();
    _status = SessionStatus.finished;
    unawaited(_cues.play(SessionCue.finished, _finishedCue));
    notifyListeners();
  }

  void _playStepCue() =>
      unawaited(_cues.play(step.kind.sessionCue, step.kind.spokenCue));

  @override
  void dispose() {
    unawaited(_cues.stop());
    _stepAnimation.dispose();
    super.dispose();
  }
}
