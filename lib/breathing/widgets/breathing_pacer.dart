import 'package:flutter/material.dart';

import '../breathing_method.dart';
import '../breathing_phase.dart';
import 'pacer_paths.dart';

/// Shows the breathing shape with a dot that travels along its outline.
/// One phase of the breathing method equals one side or loop of the shape.
class BreathingPacer extends StatelessWidget {
  const BreathingPacer({
    super.key,
    required this.animation,
    required this.method,
    required this.phaseIndex,
    required this.isFinished,
  });

  final Animation<double> animation;
  final BreathingMethod method;
  final int phaseIndex;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    final phase = method.phases[phaseIndex];
    return Semantics(
      label: isFinished
          ? 'Breathing session complete'
          : '${phase.title}. Follow the dot along the shape.',
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => SizedBox.square(
          dimension: 260,
          child: CustomPaint(
            painter: _BreathingPacerPainter(
              method: method,
              phaseIndex: phaseIndex,
              phaseProgress: animation.value,
              isFinished: isFinished,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingPacerPainter extends CustomPainter {
  _BreathingPacerPainter({
    required this.method,
    required this.phaseIndex,
    required this.phaseProgress,
    required this.isFinished,
  });

  static const _strokeWidth = 7.0;
  static const _inset = 24.0;

  final BreathingMethod method;
  final int phaseIndex;
  final double phaseProgress;
  final bool isFinished;

  @override
  void paint(Canvas canvas, Size size) {
    final path = pacerPath(method, size, _inset);
    final metric = path.computeMetrics().first;
    final segmentLength = metric.length / method.phases.length;
    final activeColor = method.phases[phaseIndex].color;

    // Draw every side or loop in the color of its phase.
    for (var i = 0; i < method.phases.length; i++) {
      final isActive = !isFinished && i == phaseIndex;
      final segment = metric.extractPath(
        segmentLength * i,
        segmentLength * (i + 1),
      );
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = method.phases[i].color.withValues(
            alpha: isActive ? 0.45 : 0.22,
          ),
      );
    }

    if (isFinished) return;

    // Draw the part of the current segment that the user has already traced.
    final start = segmentLength * phaseIndex;
    canvas.drawPath(
      metric.extractPath(start, start + segmentLength * phaseProgress),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = activeColor,
    );

    // Draw the dot that the user follows.
    final tangent = metric.getTangentForOffset(
      start + segmentLength * phaseProgress,
    );
    if (tangent != null) {
      canvas.drawCircle(
        tangent.position,
        18,
        Paint()..color = activeColor.withValues(alpha: 0.18),
      );
      canvas.drawCircle(tangent.position, 9, Paint()..color = activeColor);
    }
  }

  @override
  bool shouldRepaint(covariant _BreathingPacerPainter oldDelegate) =>
      oldDelegate.method != method ||
      oldDelegate.phaseIndex != phaseIndex ||
      oldDelegate.phaseProgress != phaseProgress ||
      oldDelegate.isFinished != isFinished;
}
