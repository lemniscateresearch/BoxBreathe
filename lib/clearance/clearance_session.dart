import '../common/step_session.dart';
import 'clearance_routine.dart';
import 'clearance_step.dart';

/// Holds the state of one airway clearance session: the selected
/// routine, the current step, and the progress through that step.
///
/// Timed steps advance on their own. A huff step waits until the user
/// calls [completeStep], because a huff and a cough take a different
/// length of time for each person.
class ClearanceSession extends StepSession<ClearanceStep> {
  ClearanceSession({
    required super.vsync,
    required super.cues,
    this.settings = ClearanceSettings.defaults,
  }) : super(finishedCue: 'Session complete. Well done.') {
    replaceSteps(_routine.steps(settings));
  }

  final ClearanceSettings settings;

  ClearanceRoutine _routine = ClearanceRoutine.acbt;

  ClearanceRoutine get routine => _routine;

  /// A routine always has steps, so the current step is never null.
  @override
  ClearanceStep get step => super.step!;

  void selectRoutine(ClearanceRoutine routine) {
    if (!canChangeSettings) return;
    _routine = routine;
    replaceSteps(routine.steps(settings));
  }
}
