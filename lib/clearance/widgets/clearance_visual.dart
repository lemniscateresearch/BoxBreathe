import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../clearance_step.dart';
import 'candle_visual.dart';

/// Shows a circle that follows the current step: it grows while the
/// user breathes in, stays full during the hold, shrinks while they
/// breathe out, and pulses gently during relaxed breathing. An outer
/// ring fills up as a timed step runs.
///
/// During a huff, a candle takes the place of the circle. When the user
/// finishes the huff, the candle blows out before the circle returns.
class ClearanceVisual extends StatefulWidget {
  const ClearanceVisual({
    super.key,
    required this.animation,
    required this.step,
    required this.isRunning,
    required this.isFinished,
  });

  final Animation<double> animation;
  final ClearanceStep step;
  final bool isRunning;
  final bool isFinished;

  @override
  State<ClearanceVisual> createState() => _ClearanceVisualState();
}

class _ClearanceVisualState extends State<ClearanceVisual> {
  bool _isBlowingOut = false;

  bool _isHuff(ClearanceStep step) => step.kind == ClearanceStepKind.huff;

  @override
  void didUpdateWidget(ClearanceVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A huff that ends while the session runs means the user tapped Done.
    // A reset or a finished session does not blow the candle out.
    if (_isHuff(oldWidget.step) && !_isHuff(widget.step) && widget.isRunning) {
      _isBlowingOut = true;
    } else if (_isHuff(widget.step) || !widget.isRunning) {
      _isBlowingOut = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final isFinished = widget.isFinished;
    final showCandle = !isFinished && (_isHuff(step) || _isBlowingOut);

    return Semantics(
      label: isFinished
          ? 'Airway clearance session complete'
          : '${step.kind.title}. ${step.kind.cue}',
      child: SizedBox.square(
        dimension: 260,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: widget.animation,
              builder: (context, _) => CustomPaint(
                size: const Size.square(260),
                painter: _ClearanceVisualPainter(
                  step: step,
                  progress: widget.animation.value,
                  isFinished: isFinished,
                  showCircle: !showCandle,
                ),
              ),
            ),
            if (showCandle)
              CandleVisual(
                mode: _isBlowingOut
                    ? CandleMode.blowOut
                    : CandleMode.demonstrate,
                onBlownOut: () => setState(() => _isBlowingOut = false),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClearanceVisualPainter extends CustomPainter {
  _ClearanceVisualPainter({
    required this.step,
    required this.progress,
    required this.isFinished,
    required this.showCircle,
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
  final bool showCircle;

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

    if (!showCircle) return;

    final radius = _radius;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color.withValues(alpha: isFinished ? 0.4 : 1),
    );
  }

  @override
  bool shouldRepaint(covariant _ClearanceVisualPainter oldDelegate) =>
      oldDelegate.step != step ||
      oldDelegate.progress != progress ||
      oldDelegate.isFinished != isFinished ||
      oldDelegate.showCircle != showCircle;
}
