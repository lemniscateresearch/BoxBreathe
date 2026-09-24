import '../clearance/clearance_routine.dart';
import '../common/step_session.dart';
import 'exercise_sequence.dart';
import 'sequence_step.dart';
import 'sequence_timeline.dart';

/// Holds the state of one sequence session: the selected sequence, its
/// steps, the current step, and the progress through that step.
///
/// Timed steps advance on their own. A step without a duration, such as
/// a huff, waits until the user calls [completeStep].
class SequenceSession extends StepSession<SequenceStep> {
  SequenceSession({
    required super.vsync,
    required super.cues,
    this.phaseLength = const Duration(seconds: 4),
    this.clearance = ClearanceSettings.defaults,
  }) : super(finishedCue: 'Sequence complete. Well done.');

  final Duration phaseLength;
  final ClearanceSettings clearance;

  ExerciseSequence? _sequence;

  ExerciseSequence? get sequence => _sequence;

  /// Selects [sequence] and builds its steps. Call it again after the
  /// user edits the sequence.
  void selectSequence(ExerciseSequence? sequence) {
    if (!canChangeSettings) return;
    _sequence = sequence;
    replaceSteps(
      sequence == null
          ? const []
          : buildTimeline(
              sequence,
              phaseLength: phaseLength,
              clearance: clearance,
            ),
    );
  }
}
