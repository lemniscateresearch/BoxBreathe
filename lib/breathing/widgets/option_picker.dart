import 'package:flutter/material.dart';

/// A heading above a centered row of choice chips. The chips are
/// disabled when [onSelected] is null.
class OptionPicker<T> extends StatelessWidget {
  const OptionPicker({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String title;
  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    final onSelected = this.onSelected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == selected,
                onSelected: onSelected == null
                    ? null
                    : (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}
