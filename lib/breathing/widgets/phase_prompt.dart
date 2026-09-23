import 'package:flutter/material.dart';

import '../breathing_phase.dart';

/// Tells the user what to do in the current phase, or that the session
/// is complete. The text cross-fades when the phase changes.
class PhasePrompt extends StatelessWidget {
  const PhasePrompt({super.key, required this.phase, required this.isFinished});

  final BreathingPhase phase;
  final bool isFinished;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    child: Column(
      key: ValueKey(isFinished ? 'finished' : phase),
      children: [
        Text(
          isFinished ? 'Session complete' : phase.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          isFinished
              ? 'Well done. Take a moment before you continue.'
              : phase.cue,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
