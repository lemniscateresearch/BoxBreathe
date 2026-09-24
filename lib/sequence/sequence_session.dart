import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../clearance/clearance_routine.dart';
import '../common/audio/cue_player.dart';
import '../common/audio/session_cue.dart';
import '../common/guided_session.dart';
import '../common/session_status.dart';
import 'exercise_sequence.dart';
import 'sequence_step.dart';
import 'sequence_timeline.dart';

/// Holds the state of one sequence session: the selected sequence, its
/// steps, the current step, and the progress through that step.
///
/// Timed steps advance on their own. A step without a duration, such as
/// a huff, waits until the user calls [completeStep].
class SequenceSession extends ChangeNotifier implements GuidedSession {
  SequenceSession({
    required TickerProvider vsync,
    required this._cues,
    this.phaseLength = const Duration(seconds: 4),
    this.clearance = ClearanceSettings.defaults,
  }) {
    _stepAnimation = AnimationController(vsync: vsync)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && isRunning) _advance();
      });
  }

  static const _finishedCue = 'Sequence complete. Well done.';

  final Duration phaseLength;
  final ClearanceSettings clearance;
  final CuePlayer _cues;
  late final AnimationController _stepAnimation;

  ExerciseSequence? _sequence;
  List<SequenceStep> _steps = const [];
  int _stepIndex = 0;
  SessionStatus _status = SessionStatus.idle;

  ExerciseSequence? get sequence => _sequence;
  List<SequenceStep> get steps => _steps;
  int get stepIndex => _stepIndex;

  /// The current step, or null when the sequence has no steps.
  SequenceStep? get step => _steps.isEmpty ? null : _steps[_stepIndex];

  @override
  SessionStatus get status => _status;

  /// Goes from 0 to 1 during each timed step. It stays at 0 during a
  /// step that waits for the user.
  Animation<double> get stepProgress => _stepAnimation;

  bool get isRunning => _status == SessionStatus.running;
  bool get isFinished => _status == SessionStatus.finished;
  bool get isWaitingForUser => isRunning && (step?.waitsForUser ?? false);
  bool get canStart => _steps.isNotEmpty;

  /// The user can change the sequence only when no session is in
  /// progress.
  bool get canChangeSettings =>
      _status == SessionStatus.idle || _status == SessionStatus.finished;

  /// Selects [sequence] and builds its steps. Call it again after the
  /// user edits the sequence.
  void selectSequence(ExerciseSequence? sequence) {
    if (!canChangeSettings) return;
    _sequence = sequence;
    _steps = sequence == null
        ? const []
        : buildTimeline(
            sequence,
            phaseLength: phaseLength,
            clearance: clearance,
          );
    reset();
  }

  void startOrResume() {
    if (!canStart) return;
    final isResuming = _status == SessionStatus.paused;
    if (isFinished) _stepIndex = 0;
    _status = SessionStatus.running;

    if (isResuming) {
      if (!step!.waitsForUser) _stepAnimation.forward();
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

  /// Moves on from a step that waits for the user, when they tap Done.
  void completeStep() {
    if (isWaitingForUser) _advance();
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
