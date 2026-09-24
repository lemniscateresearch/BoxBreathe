import 'package:flutter/material.dart';

import '../session_status.dart';
import '../step_session.dart';
import 'session_buttons.dart';

/// The primary button, with a reset button next to it. At a step that
/// waits for the user, such as a huff, the primary button becomes Done.
/// The start button is disabled while the session has no steps.
class StepSessionControls extends StatelessWidget {
  const StepSessionControls({super.key, required this.session});

  final StepSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.status;
    final start = session.canStart ? session.startOrResume : null;

    final (label, icon, onPressed) = switch (status) {
      _ when session.isWaitingForUser => (
        'Done',
        Icons.check_rounded,
        session.completeStep,
      ),
      SessionStatus.running => (
        'Pause session',
        Icons.pause_rounded,
        session.pause,
      ),
      SessionStatus.paused => (
        'Resume session',
        Icons.play_arrow_rounded,
        start,
      ),
      SessionStatus.finished => (
        'Start again',
        Icons.play_arrow_rounded,
        start,
      ),
      SessionStatus.idle => ('Start session', Icons.play_arrow_rounded, start),
    };

    return SessionButtons(
      label: label,
      icon: icon,
      onPressed: onPressed,
      onReset: status == SessionStatus.idle ? null : session.reset,
    );
  }
}
