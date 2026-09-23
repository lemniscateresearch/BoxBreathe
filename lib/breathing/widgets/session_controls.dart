import 'package:flutter/material.dart';

import '../breathing_session.dart';

/// The primary start, pause, and resume button, with a reset button
/// below it.
class SessionControls extends StatelessWidget {
  const SessionControls({super.key, required this.session});

  final BreathingSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.status;
    final isRunning = status == SessionStatus.running;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isRunning ? session.pause : session.startOrResume,
          icon: Icon(
            isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
          label: Text(switch (status) {
            SessionStatus.idle => 'Start session',
            SessionStatus.running => 'Pause session',
            SessionStatus.paused => 'Resume session',
            SessionStatus.finished => 'Start again',
          }),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: status == SessionStatus.idle ? null : session.reset,
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
