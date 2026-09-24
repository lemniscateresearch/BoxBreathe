import 'package:flutter/material.dart';

/// Reminds the user to follow their clinical advice. Every page that
/// offers airway clearance shows it.
class SafetyNote extends StatelessWidget {
  const SafetyNote({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Follow the advice of your physiotherapist or respiratory team. '
    'Stop and rest if you feel dizzy or short of breath.',
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 13,
    ),
  );
}
