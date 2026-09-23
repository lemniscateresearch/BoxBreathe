import 'clearance_step.dart';

/// The counts and durations of an airway clearance session.
///
/// The app uses [defaults] for now. To make the routine adjustable, give
/// the user a way to edit these values and pass the result to the
/// session.
class ClearanceSettings {
  const ClearanceSettings({
    required this.cycles,
    required this.breathingControl,
    required this.deepBreaths,
    required this.deepBreathIn,
    required this.deepBreathHold,
    required this.deepBreathOut,
    required this.huffsPerSet,
  });

  /// Common starting values for the Active Cycle of Breathing Technique.
  /// A physiotherapist can prescribe different values.
  static const defaults = ClearanceSettings(
    cycles: 3,
    breathingControl: Duration(seconds: 30),
    deepBreaths: 3,
    deepBreathIn: Duration(seconds: 4),
    deepBreathHold: Duration(seconds: 3),
    deepBreathOut: Duration(seconds: 4),
    huffsPerSet: 2,
  );

  final int cycles;
  final Duration breathingControl;
  final int deepBreaths;
  final Duration deepBreathIn;
  final Duration deepBreathHold;
  final Duration deepBreathOut;
  final int huffsPerSet;
}

enum ClearanceRoutine { acbt, huffsWithRests }

extension ClearanceRoutineDetails on ClearanceRoutine {
  String get label => switch (this) {
    ClearanceRoutine.acbt => 'Full cycle (ACBT)',
    ClearanceRoutine.huffsWithRests => 'Huffs with rests',
  };

  String get description => switch (this) {
    ClearanceRoutine.acbt =>
      'Relaxed breathing, deep breaths, then huffs to move mucus up.',
    ClearanceRoutine.huffsWithRests =>
      'Huffs to move mucus up, with relaxed breathing in between.',
  };

  /// Expands the routine into the steps of a full session. Every session
  /// ends with relaxed breathing.
  List<ClearanceStep> steps(ClearanceSettings settings) {
    final steps = <ClearanceStep>[];

    void rest(int cycle) => steps.add(
      ClearanceStep(
        kind: ClearanceStepKind.breathingControl,
        duration: settings.breathingControl,
        cycle: cycle,
      ),
    );

    for (var cycle = 1; cycle <= settings.cycles; cycle++) {
      rest(cycle);

      if (this == ClearanceRoutine.acbt) {
        for (var breath = 1; breath <= settings.deepBreaths; breath++) {
          for (final (kind, duration) in [
            (ClearanceStepKind.deepBreathIn, settings.deepBreathIn),
            (ClearanceStepKind.deepBreathHold, settings.deepBreathHold),
            (ClearanceStepKind.deepBreathOut, settings.deepBreathOut),
          ]) {
            steps.add(
              ClearanceStep(
                kind: kind,
                duration: duration,
                cycle: cycle,
                repetition: breath,
                repetitions: settings.deepBreaths,
              ),
            );
          }
        }
        rest(cycle);
      }

      for (var huff = 1; huff <= settings.huffsPerSet; huff++) {
        if (huff > 1) rest(cycle);
        steps.add(
          ClearanceStep(
            kind: ClearanceStepKind.huff,
            duration: null,
            cycle: cycle,
            repetition: huff,
            repetitions: settings.huffsPerSet,
          ),
        );
      }
    }

    rest(settings.cycles);
    return steps;
  }
}
