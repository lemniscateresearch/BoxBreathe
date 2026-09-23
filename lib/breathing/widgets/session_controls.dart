import 'package:flutter/material.dart';

import '../../common/session_status.dart';
import '../../common/widgets/session_buttons.dart';
import '../breathing_session.dart';

/// The start, pause, and resume button, with a reset button next to it.
class SessionControls extends StatelessWidget {
  const SessionControls({super.key, required this.session});

  final BreathingSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.status;
    final isRunning = status == SessionStatus.running;

    return SessionButtons(
      label: switch (status) {
        SessionStatus.idle => 'Start session',
        SessionStatus.running => 'Pause session',
        SessionStatus.paused => 'Resume session',
        SessionStatus.finished => 'Start again',
      },
      icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
      onPressed: isRunning ? session.pause : session.startOrResume,
      onReset: status == SessionStatus.idle ? null : session.reset,
    );
  }
}
