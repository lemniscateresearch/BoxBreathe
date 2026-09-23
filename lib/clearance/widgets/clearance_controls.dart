import 'package:flutter/material.dart';

import '../../common/session_status.dart';
import '../clearance_session.dart';

/// The primary button, with a reset button below it. At a huff step the
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
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
