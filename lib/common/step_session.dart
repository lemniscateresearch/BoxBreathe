import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'audio/cue_player.dart';
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
    required CuePlayer cues,
    required String finishedCue,
  }) {
    // TODO(Lilly): set up the state and the AnimationController.
    throw UnimplementedError();
  }

  /// The steps of the session, in order.
  List<S> get steps => throw UnimplementedError();

  /// The position of [step] in [steps].
  int get stepIndex => throw UnimplementedError();

  /// The current step, or null when there are no steps.
  S? get step => throw UnimplementedError();

  @override
  SessionStatus get status => throw UnimplementedError();

  /// Goes from 0 to 1 during each timed step. It stays at 0 during a step
  /// that waits for the user.
  Animation<double> get stepProgress => throw UnimplementedError();

  bool get isRunning => throw UnimplementedError();
  bool get isFinished => throw UnimplementedError();

  /// True when the session runs and the current step waits for the user.
  bool get isWaitingForUser => throw UnimplementedError();

  /// A session can start only when it has steps.
  bool get canStart => throw UnimplementedError();

  /// The user can change the settings only when no session is in
  /// progress, that is, when it is idle or finished.
  bool get canChangeSettings => throw UnimplementedError();

  /// Starts from the first step, resumes after a pause, or starts again
  /// after the session finished. Does nothing when [canStart] is false.
  void startOrResume() => throw UnimplementedError();

  /// Stops the step progress and the cues. Does nothing unless the
  /// session runs.
  void pause() => throw UnimplementedError();

  /// Goes back to the first step, with the session idle.
  void reset() => throw UnimplementedError();

  /// Moves on from a step that waits for the user, when they tap Done.
  /// Does nothing at other times.
  void completeStep() => throw UnimplementedError();

  /// Sets new steps and resets the session. Does nothing unless
  /// [canChangeSettings] is true.
  @protected
  void replaceSteps(List<S> steps) => throw UnimplementedError();

  @override
  void dispose() {
    // TODO(Lilly): stop the cues and dispose of the AnimationController.
    super.dispose();
  }
}
