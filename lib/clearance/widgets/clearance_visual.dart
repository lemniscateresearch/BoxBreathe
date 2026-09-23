import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../clearance_step.dart';

/// Shows a circle that follows the current step: it grows while the
/// user breathes in, stays full during the hold, shrinks while they
/// breathe out, and pulses gently during relaxed breathing. An outer
/// ring fills up as a timed step runs.
class ClearanceVisual extends StatelessWidget {
  const ClearanceVisual({
    super.key,
    required this.animation,
    required this.step,
    required this.isFinished,
  });

  final Animation<double> animation;
  final ClearanceStep step;
  final bool isFinished;

  @override
  Widget build(BuildContext context) => Semantics(
    label: isFinished
        ? 'Airway clearance session complete'
        : '${step.kind.title}. ${step.kind.cue}',
    child: SizedBox.square(
      dimension: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => CustomPaint(
              size: const Size.square(260),
              painter: _ClearanceVisualPainter(
                step: step,
                progress: animation.value,
                isFinished: isFinished,
              ),
            ),
          ),
          if (!isFinished && step.kind == ClearanceStepKind.huff)
            const ExcludeSemantics(
              child: Text(
                'Huff',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _ClearanceVisualPainter extends CustomPainter {
  _ClearanceVisualPainter({
    required this.step,
    required this.progress,
    required this.isFinished,
  });

  static const _minRadius = 52.0;
  static const _maxRadius = 104.0;
  static const _ringRadius = 122.0;
  static const _ringWidth = 6.0;

  /// One gentle pulse about every five seconds of relaxed breathing.
  static const _pulseLength = Duration(seconds: 5);

  final ClearanceStep step;
  final double progress;
  final bool isFinished;

  double get _radius {
    if (isFinished) return _minRadius;
    final eased = Curves.easeInOut.transform(progress);
    return switch (step.kind) {
      ClearanceStepKind.deepBreathIn =>
        _minRadius + (_maxRadius - _minRadius) * eased,
      ClearanceStepKind.deepBreathHold || ClearanceStepKind.huff => _maxRadius,
      ClearanceStepKind.deepBreathOut =>
        _maxRadius - (_maxRadius - _minRadius) * eased,
      ClearanceStepKind.breathingControl => _pulseRadius,
    };
  }

  double get _pulseRadius {
    final duration = step.duration ?? _pulseLength;
    final pulses = math.max(
      1,
      (duration.inMilliseconds / _pulseLength.inMilliseconds).round(),
    );
    final wave = math.sin(2 * math.pi * pulses * progress);
    return (_minRadius + _maxRadius) / 2 + 8 * wave;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final color = step.kind.color;

    // The track for the progress ring.
    canvas.drawCircle(
      center,
      _ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..color = color.withValues(alpha: 0.15),
    );

    if (!isFinished && !step.waitsForUser) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: _ringRadius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringWidth
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }

    final radius = _radius;
    final isHuff = !isFinished && step.kind == ClearanceStepKind.huff;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color.withValues(alpha: isHuff ? 1 : 0.22),
    );
    if (!isHuff) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = color.withValues(alpha: isFinished ? 0.4 : 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClearanceVisualPainter oldDelegate) =>
      oldDelegate.step != step ||
      oldDelegate.progress != progress ||
      oldDelegate.isFinished != isFinished;
}
