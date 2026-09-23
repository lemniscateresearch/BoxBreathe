import 'package:flutter/material.dart';

/// A button that shows the current session options, such as
/// "Box · 3 min". A tap on it opens the setup sheet.
class SetupSummaryButton extends StatelessWidget {
  const SetupSummaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      hint: 'Change the session options',
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: const Icon(Icons.tune_rounded),
        label: Text(label),
      ),
    ),
  );
}

/// Opens a bottom sheet with the session options. The sheet rebuilds
/// when [listenable] changes, so a new choice shows immediately.
Future<void> showSetupSheet(
  BuildContext context, {
  required Listenable listenable,
  required WidgetBuilder builder,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: listenable,
            builder: (context, _) => builder(context),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    ),
  ),
);
