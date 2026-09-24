import 'package:flutter/material.dart';

import '../../breathing/widgets/breathing_pacer.dart';
import '../../clearance/clearance_step.dart';
import '../../clearance/widgets/clearance_visual.dart';
import '../sequence_segment.dart';
import '../sequence_session.dart';
import '../sequence_step.dart';

/// Shows the visual of the current step: the breathing pacer for a
/// breathing shape, and the clearance circle or candle for airway
/// clearance. During a transition, it shows the start of the next
/// segment. The visuals cross-fade when a new segment starts.
class SequenceVisual extends StatelessWidget {
  const SequenceVisual({super.key, required this.session});

  static const _fadeDuration = Duration(milliseconds: 400);
  static const _stopped = AlwaysStoppedAnimation(0.0);

  final SequenceSession session;

  @override
  Widget build(BuildContext context) {
    final step = session.step;
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : _fadeDuration,
      child: KeyedSubtree(
        key: ValueKey(step?.segmentIndex),
        child: step == null ? _empty(context) : _forStep(step),
      ),
    );
  }

  Widget _forStep(SequenceStep step) => switch (step) {
    BreathPhaseStep(:final method, :final phaseIndex) => BreathingPacer(
      animation: session.stepProgress,
      method: method,
      phaseIndex: phaseIndex,
      isFinished: session.isFinished,
    ),
    ClearanceSequenceStep(step: final clearanceStep) => ClearanceVisual(
      animation: session.stepProgress,
      step: clearanceStep,
      isRunning: session.isRunning,
      isFinished: session.isFinished,
    ),
    // The prompt says what comes next, so the preview has no label.
    TransitionStep(:final next) => ExcludeSemantics(child: _preview(next)),
  };

  /// The first visual of [segment], standing still.
  Widget _preview(SequenceSegment segment) => switch (segment) {
    BreathingSegment(:final method) => BreathingPacer(
      animation: _stopped,
      method: method,
      phaseIndex: 0,
      isFinished: false,
    ),
    ClearanceSegment() => ClearanceVisual(
      animation: _stopped,
      step: ClearanceStep(
        kind: ClearanceStepKind.breathingControl,
        duration: session.clearance.breathingControl,
        cycle: 1,
      ),
      isRunning: false,
      isFinished: false,
    ),
  };

  Widget _empty(BuildContext context) => SizedBox.square(
    dimension: 260,
    child: Icon(
      Icons.playlist_add_rounded,
      size: 120,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}
