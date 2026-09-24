import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'audio/cue_player.dart';
import 'audio/session_cue.dart';
import 'guided_session.dart';
import 'session_status.dart';
import 'timed_step.dart';

/// Runs a list of [TimedStep]s in order: the engine behind the breathing,
/// airway clearance and sequence pages.
///
/// Timed steps move on by themselves. A step without a duration waits
/// until the user calls [completeStep]. When the last step ends, the
/// session plays the finished cue and its status becomes
/// [SessionStatus.finished].
///
/// Subclasses hold the page's settings (a routine, a sequence, a breathing
/// method) and call [replaceSteps] when those settings change.
abstract class StepSession<S extends TimedStep> extends ChangeNotifier
    implements GuidedSession {
  StepSession({
    required TickerProvider vsync,
    required this._cues,
    required this._finishedCue,
  }) {
    _stepAnimation = AnimationController(vsync: vsync)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && isRunning) _advance();
      });
  }

  final CuePlayer _cues;
  final String _finishedCue;
  late final AnimationController _stepAnimation;

  List<S> _steps = const [];
  int _stepIndex = 0;
  SessionStatus _status = SessionStatus.idle;

  /// The steps of the session, in order.
  List<S> get steps => _steps;

  /// The position of [step] in [steps].
  int get stepIndex => _stepIndex;

  /// The current step, or null when there are no steps.
  S? get step => _steps.isEmpty ? null : _steps[_stepIndex];

  @override
  SessionStatus get status => _status;

  /// Goes from 0 to 1 during each timed step. It stays at 0 during a step
  /// that waits for the user.
  Animation<double> get stepProgress => _stepAnimation;

  bool get isRunning => _status == SessionStatus.running;
  bool get isFinished => _status == SessionStatus.finished;

  /// True when the session runs and the current step waits for the user.
  bool get isWaitingForUser => isRunning && _waitsForUser;

  /// A session can start only when it has steps.
  bool get canStart => _steps.isNotEmpty;

  /// The user can change the settings only when no session is in
  /// progress, that is, when it is idle or finished.
  bool get canChangeSettings =>
      _status == SessionStatus.idle || _status == SessionStatus.finished;

  bool get _waitsForUser => step?.duration == null;

  /// Starts from the first step, resumes after a pause, or starts again
  /// after the session finished. Does nothing when [canStart] is false.
  void startOrResume() {
    if (!canStart) return;
    final isResuming = _status == SessionStatus.paused;
    if (isFinished) _stepIndex = 0;
    _status = SessionStatus.running;

    if (isResuming) {
      if (!_waitsForUser) _stepAnimation.forward();
      _playStepCue();
      notifyListeners();
    } else {
      _beginStep();
    }
  }

  /// Stops the step progress and the cues. Does nothing unless the
  /// session runs.
  void pause() {
    if (!isRunning) return;
    _status = SessionStatus.paused;
    _stepAnimation.stop();
    unawaited(_cues.stop());
    notifyListeners();
  }

  /// Goes back to the first step, with the session idle.
  void reset() {
    _stepAnimation.reset();
    _stepIndex = 0;
    _status = SessionStatus.idle;
    unawaited(_cues.stop());
    notifyListeners();
  }

  /// Moves on from a step that waits for the user, when they tap Done.
  /// Does nothing at other times.
  void completeStep() {
    if (isWaitingForUser) _advance();
  }

  /// Sets new steps and resets the session. Does nothing unless
  /// [canChangeSettings] is true.
  @protected
  void replaceSteps(List<S> steps) {
    if (!canChangeSettings) return;
    _steps = steps;
    reset();
  }

  void _beginStep() {
    _stepAnimation.reset();
    final duration = step!.duration;
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
      unawaited(_cues.play(step!.sessionCue, step!.spokenCue));

  @override
  void dispose() {
    unawaited(_cues.stop());
    _stepAnimation.dispose();
    super.dispose();
  }
}
