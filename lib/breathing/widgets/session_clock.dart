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
    return switch ((breathsRemaining, minutesRemaining)) {
      (_, 0) => "All breaths finished.",
      (1, _) => "1 breath remaining.",
      _ => '$breathsRemaining breaths, about $minutesRemaining min.',
    };
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
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
