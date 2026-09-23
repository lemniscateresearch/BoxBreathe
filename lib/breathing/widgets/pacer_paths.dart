import 'dart:math' as math;
import 'dart:ui';

import '../breathing_method.dart';

/// Builds the outline that the breathing dot travels along.
///
/// The path starts at the beginning of the first phase and has one
/// equally-long segment for each phase in [BreathingMethodDetails.phases].
Path pacerPath(BreathingMethod method, Size size, double inset) =>
    switch (method) {
      BreathingMethod.box => _boxPath(size, inset),
      BreathingMethod.figureEight => _figureEightPath(size, inset),
      BreathingMethod.triangle => _trianglePath(size, inset),
    };

Path _boxPath(Size size, double inset) {
  final left = inset;
  final top = inset;
  final right = size.width - inset;
  final bottom = size.height - inset;
  return Path()
    ..moveTo(left, bottom)
    ..lineTo(left, top)
    ..lineTo(right, top)
    ..lineTo(right, bottom)
    ..close();
}

Path _trianglePath(Size size, double inset) {
  // Equilateral triangle so that all three sides have the same length.
  final side = size.width - 2 * inset;
  final height = side * math.sqrt(3) / 2;
  final centerX = size.width / 2;
  final top = inset + (size.height - height) / 2;
  final bottom = top + height;
  return Path()
    ..moveTo(centerX - side / 2, bottom)
    ..lineTo(centerX, top)
    ..lineTo(centerX + side / 2, bottom)
    ..close();
}

Path _figureEightPath(Size size, double inset) {
  // Gerono lemniscate: x = a * cos(t), y = b * sin(2t) / 2.
  // The path starts at the center crossing. The first half of the path
  // traces the right loop (breathe in), the second half traces the left
  // loop (breathe out).
  final centerX = size.width / 2;
  final centerY = size.height / 2;
  final amplitudeX = size.width / 2 - inset;
  final amplitudeY = size.height / 2 - inset;
  const samples = 96;
  final path = Path();
  for (var i = 0; i <= samples; i++) {
    final t = -math.pi / 2 + (2 * math.pi * i) / samples;
    final x = centerX + amplitudeX * math.cos(t);
    final y = centerY - amplitudeY * math.sin(2 * t);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  return path;
}
