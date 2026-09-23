import 'package:flutter/painting.dart';

enum BreathingPhase { inhale, holdAfterInhale, exhale, holdAfterExhale }

extension BreathingPhaseDetails on BreathingPhase {
  String get title => switch (this) {
    BreathingPhase.inhale => 'Breathe in',
    BreathingPhase.holdAfterInhale || BreathingPhase.holdAfterExhale => 'Hold',
    BreathingPhase.exhale => 'Breathe out',
  };

  String get cue => switch (this) {
    BreathingPhase.inhale => 'Let the shape guide your breath in.',
    BreathingPhase.holdAfterInhale => 'Keep a gentle, comfortable hold.',
    BreathingPhase.exhale => 'Let the shape guide your breath out.',
    BreathingPhase.holdAfterExhale => 'Rest here before the next breath.',
  };

  Color get color => switch (this) {
    BreathingPhase.inhale => const Color(0xFF398F7B),
    BreathingPhase.holdAfterInhale => const Color(0xFF246457),
    BreathingPhase.exhale => const Color(0xFF6B8DC4),
    BreathingPhase.holdAfterExhale => const Color(0xFF5974A4),
  };
}
