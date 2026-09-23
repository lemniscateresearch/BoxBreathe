import 'package:flutter/material.dart';

import '../../common/session_status.dart';
import '../../common/widgets/session_buttons.dart';
import '../clearance_session.dart';

/// The primary button, with a reset button next to it. At a huff step the
/// primary button becomes Done, so the user can move on when they are
/// ready.
class ClearanceControls extends StatelessWidget {
  const ClearanceControls({super.key, required this.session});

  final ClearanceSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.status;
    final isWaitingForHuff = session.isWaitingForHuff;

    final (label, icon, onPressed) = switch (status) {
      _ when isWaitingForHuff => (
        'Done',
        Icons.check_rounded,
        session.completeHuff,
      ),
      SessionStatus.running => (
        'Pause session',
        Icons.pause_rounded,
        session.pause,
      ),
      SessionStatus.paused => (
        'Resume session',
        Icons.play_arrow_rounded,
        session.startOrResume,
      ),
      SessionStatus.finished => (
        'Start again',
        Icons.play_arrow_rounded,
        session.startOrResume,
      ),
      SessionStatus.idle => (
        'Start session',
        Icons.play_arrow_rounded,
        session.startOrResume,
      ),
    };

    return SessionButtons(
      label: label,
      icon: icon,
      onPressed: onPressed,
      onReset: status == SessionStatus.idle ? null : session.reset,
    );
  }
}
