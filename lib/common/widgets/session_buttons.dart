import 'package:flutter/material.dart';

/// The primary session button, with a small reset button next to it.
/// The reset button is disabled when [onReset] is null.
class SessionButtons extends StatelessWidget {
  const SessionButtons({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.onReset,
  });

  static const _height = 52.0;

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(_height),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      IconButton.outlined(
        onPressed: onReset,
        icon: const Icon(Icons.restart_alt_rounded),
        tooltip: 'Reset',
        style: IconButton.styleFrom(minimumSize: const Size.square(_height)),
      ),
    ],
  );
}
