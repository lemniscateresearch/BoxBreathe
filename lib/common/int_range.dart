/// The permitted values of a whole-number setting: from [min] to [max]
/// in steps of [step].
class IntRange {
  const IntRange(this.min, this.max, {this.step = 1});

  final int min;
  final int max;
  final int step;

  /// Moves [value] to the nearest permitted value.
  int clamp(int value) {
    final stepped = min + ((value - min) / step).round() * step;
    return stepped.clamp(min, max);
  }

  bool contains(int value) => value == clamp(value);
}
