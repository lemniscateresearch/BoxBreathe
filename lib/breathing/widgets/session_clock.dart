import 'package:flutter/material.dart';

/// Shows the time that remains in the session as `m:ss`.
class SessionClock extends StatelessWidget {
  const SessionClock({super.key, required this.secondsRemaining});

  final int secondsRemaining;

  String get _formatted {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Session time remaining: $_formatted',
    child: Text(
      _formatted,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    ),
  );
}
