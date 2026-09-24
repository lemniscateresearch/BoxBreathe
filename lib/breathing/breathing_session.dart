import 'dart:math';

import 'package:flutter/animation.dart';

import '../common/step_session.dart';
import 'breath_step.dart';
import 'breathing_method.dart';
import 'breathing_phase.dart';

/// Holds the state of one breathing session: the selected method and
/// length, the current phase, and the progress through that phase.
///
/// The chosen length becomes a whole number of breaths, so a session
/// always ends after a full breath. It can end a few seconds before the
/// chosen length.
///
/// The widgets read this state and call its methods. They keep no
/// session state of their own.
class BreathingSession extends StepSession<BreathStep> {
  BreathingSession({
    required super.vsync,
    required super.cues,
    this.phaseLength = const Duration(seconds: 4),
  }) : super(finishedCue: 'Session complete. Well done.') {
    _rebuildSteps();
  }

  static const lengthOptions = [1, 3, 5, 10];

  final Duration phaseLength;

  BreathingMethod _method = BreathingMethod.box;
  int _minutes = 3;

  BreathingMethod get method => _method;
  int get minutes => _minutes;

  /// There is always at least one breath, so the step is never null.
  @override
  BreathStep get step => super.step!;

  int get phaseIndex => step.phaseIndex;
  BreathingPhase get phase => step.phase;

  /// Goes from 0 to 1 during each phase.
  Animation<double> get phaseProgress => stepProgress;

  /// The number of whole breaths that fit in the chosen length.
  int get breaths {
    final breathLength = phaseLength * _method.phases.length;
    return max(1, (_minutes * 60 * 1000) ~/ breathLength.inMilliseconds);
  }

  /// The time left in the session, rounded up to a whole second. It
  /// changes with [stepProgress], not only when the session notifies.
  int get secondsRemaining {
    final stepsLeft = steps.length - stepIndex - stepProgress.value;
    return (stepsLeft * phaseLength.inMilliseconds / 1000).ceil();
  }

  void selectMethod(BreathingMethod method) {
    if (!canChangeSettings) return;
    _method = method;
    _rebuildSteps();
  }

  void selectLength(int minutes) {
    if (!canChangeSettings) return;
    _minutes = minutes;
    _rebuildSteps();
  }

  void _rebuildSteps() {
    final breaths = this.breaths;
    replaceSteps([
      for (var breath = 1; breath <= breaths; breath++)
        for (var i = 0; i < _method.phases.length; i++)
          BreathStep(
            method: _method,
            phaseIndex: i,
            breath: breath,
            breaths: breaths,
            duration: phaseLength,
          ),
    ]);
  }
}
