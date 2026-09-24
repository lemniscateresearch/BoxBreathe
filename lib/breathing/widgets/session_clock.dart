import 'package:flutter/material.dart';

/// Shows the time that remains in the session as an exact breath count and an
/// approximate time in minutes.
class SessionClock extends StatelessWidget {
  const SessionClock({
    super.key,
    required this.secondsRemaining,
    required this.breathsRemaining,
  });

  final int secondsRemaining;
  final int breathsRemaining;

  String get _formatted {
    final minutesRemaining = (secondsRemaining / 60).ceil();
    return '$breathsRemaining breaths, about $minutesRemaining min.';
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Session time remaining: $_formatted',
    child: Text(
      _formatted,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    ),
  );
}
