import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../common/audio/cue_player.dart';
import '../common/audio/session_cue.dart';
import '../common/guided_session.dart';
import '../common/session_status.dart';
import 'breathing_method.dart';
import 'breathing_phase.dart';

/// Holds the state of one breathing session: the selected method and
/// length, the countdown, and the progress through the current phase.
///
/// The widgets read this state and call its methods. They keep no
/// session state of their own.
class BreathingSession extends ChangeNotifier implements GuidedSession {
  BreathingSession({
    required TickerProvider vsync,
    required this._cues,
    Duration phaseLength = const Duration(seconds: 4),
  }) {
    _phaseAnimation = AnimationController(vsync: vsync, duration: phaseLength)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && isRunning) _advancePhase();
      });
  }

  static const lengthOptions = [1, 3, 5, 10];

  final CuePlayer _cues;

  late final AnimationController _phaseAnimation;
  Timer? _countdown;

  BreathingMethod _method = BreathingMethod.box;
  int _minutes = 3;
  int _secondsRemaining = 3 * 60;
  int _phaseIndex = 0;
  SessionStatus _status = SessionStatus.idle;

  BreathingMethod get method => _method;
  int get minutes => _minutes;
  int get secondsRemaining => _secondsRemaining;
  int get phaseIndex => _phaseIndex;
  BreathingPhase get phase => _method.phases[_phaseIndex];
  @override
  SessionStatus get status => _status;

  /// Goes from 0 to 1 during each phase.
  Animation<double> get phaseProgress => _phaseAnimation;

  bool get isRunning => _status == SessionStatus.running;
  bool get isFinished => _status == SessionStatus.finished;

  /// The user can change the method and length only when no session is
  /// in progress.
  bool get canChangeSettings =>
      _status == SessionStatus.idle || _status == SessionStatus.finished;

  void startOrResume() {
    if (isFinished) {
      _secondsRemaining = _minutes * 60;
      _phaseIndex = 0;
      _phaseAnimation.reset();
    }
    _status = SessionStatus.running;
    notifyListeners();
    _phaseAnimation.forward();
    _playPhaseCue();
    _countdown ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _status = SessionStatus.paused;
    notifyListeners();
    _phaseAnimation.stop();
    unawaited(_cues.stop());
  }

  void reset() {
    _stopCountdown();
    _phaseAnimation.reset();
    unawaited(_cues.stop());
    _status = SessionStatus.idle;
    _phaseIndex = 0;
    _secondsRemaining = _minutes * 60;
    notifyListeners();
  }

  void selectMethod(BreathingMethod method) {
    if (!canChangeSettings) return;
    _phaseAnimation.reset();
    _method = method;
    _phaseIndex = 0;
    notifyListeners();
  }

  void selectLength(int minutes) {
    if (!canChangeSettings) return;
    _minutes = minutes;
    _secondsRemaining = minutes * 60;
    _status = SessionStatus.idle;
    notifyListeners();
  }

  void _tick() {
    if (!isRunning) return;
    if (_secondsRemaining <= 1) {
      _finish();
    } else {
      _secondsRemaining--;
      notifyListeners();
    }
  }

  void _finish() {
    _stopCountdown();
    _phaseAnimation.stop();
    _secondsRemaining = 0;
    _status = SessionStatus.finished;
    notifyListeners();
    unawaited(_cues.play(SessionCue.finished, 'Session complete. Well done.'));
  }

  void _advancePhase() {
    _phaseIndex = (_phaseIndex + 1) % _method.phases.length;
    notifyListeners();
    _playPhaseCue();
    _phaseAnimation
      ..reset()
      ..forward();
  }

  void _playPhaseCue() => unawaited(_cues.play(phase.sessionCue, phase.title));

  void _stopCountdown() {
    _countdown?.cancel();
    _countdown = null;
  }

  @override
  void dispose() {
    _stopCountdown();
    unawaited(_cues.stop());
    _phaseAnimation.dispose();
    super.dispose();
  }
}
