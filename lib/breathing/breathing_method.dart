import 'breathing_phase.dart';

enum BreathingMethod { box, figureEight, triangle }

extension BreathingMethodDetails on BreathingMethod {
  String get label => switch (this) {
    BreathingMethod.box => 'Box',
    BreathingMethod.figureEight => 'Figure eight',
    BreathingMethod.triangle => 'Triangle',
  };

  String get description => switch (this) {
    BreathingMethod.box => 'Trace the square. In, hold, out, hold.',
    BreathingMethod.figureEight =>
      'Trace the eight. In on one loop, out on the other.',
    BreathingMethod.triangle => 'Trace the triangle. In, hold, out.',
  };

  /// The phases of one breath, in order. The pacer shape has one
  /// equally-long segment for each phase.
  List<BreathingPhase> get phases => switch (this) {
    BreathingMethod.box => const [
      BreathingPhase.inhale,
      BreathingPhase.holdAfterInhale,
      BreathingPhase.exhale,
      BreathingPhase.holdAfterExhale,
    ],
    BreathingMethod.figureEight => const [
      BreathingPhase.inhale,
      BreathingPhase.exhale,
    ],
    BreathingMethod.triangle => const [
      BreathingPhase.inhale,
      BreathingPhase.holdAfterInhale,
      BreathingPhase.exhale,
    ],
  };
}
