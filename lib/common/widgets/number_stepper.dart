import 'package:flutter/material.dart';

import '../int_range.dart';

/// A label with − and + buttons that change a whole number within
/// [range].
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.range,
    required this.onChanged,
    this.unit = '',
  });

  final String label;
  final int value;
  final IntRange range;
  final ValueChanged<int> onChanged;

  /// Text after the value, for example ' s'.
  final String unit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        IconButton.outlined(
          icon: const Icon(Icons.remove_rounded),
          tooltip: 'Decrease $label',
          onPressed: value > range.min
              ? () => onChanged(value - range.step)
              : null,
        ),
        SizedBox(
          width: 64,
          child: Text(
            '$value$unit',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton.outlined(
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Increase $label',
          onPressed: value < range.max
              ? () => onChanged(value + range.step)
              : null,
        ),
      ],
    ),
  );
}
