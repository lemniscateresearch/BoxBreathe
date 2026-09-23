import 'package:flutter/material.dart';

/// Tells the user what to do now: a large title with a short message
/// below it. The text cross-fades when [switchKey] changes.
class StepPrompt extends StatelessWidget {
  const StepPrompt({
    super.key,
    required this.switchKey,
    required this.title,
    required this.message,
  });

  final Object switchKey;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    child: Column(
      key: ValueKey(switchKey),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          message,
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
