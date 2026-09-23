import 'dart:math' as math;

import 'package:flutter/material.dart';

enum CandleMode {
  /// Loops as a demonstration: the flame burns, leans and goes out, the
  /// smoke rises, and the flame lights again.
  demonstrate,

  /// Plays once: the flame leans, goes out, and the smoke rises. Then
  /// the widget calls [CandleVisual.onBlownOut].
  blowOut,
}

/// A candle that shows how a huff moves the air: short, strong, and
/// enough to blow the flame out.
///
/// When the platform asks for reduced motion, the candle stays lit and
/// still, and a blow-out ends at once.
class CandleVisual extends StatefulWidget {
  const CandleVisual({
    super.key,
    this.mode = CandleMode.demonstrate,
    this.onBlownOut,
  });

  final CandleMode mode;
  final VoidCallback? onBlownOut;

  @override
  State<CandleVisual> createState() => _CandleVisualState();
}

class _CandleVisualState extends State<CandleVisual>
    with SingleTickerProviderStateMixin {
  static const _loopLength = Duration(milliseconds: 2800);
  static const _blowOutLength = Duration(milliseconds: 700);

  late final AnimationController _controller = AnimationController(vsync: this);
  bool? _reduceMotion;

  bool get _isStill => _reduceMotion ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _start();
    }
  }

  @override
  void didUpdateWidget(CandleVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) _start();
  }

  void _start() {
    _controller.stop();
    switch (widget.mode) {
      case CandleMode.demonstrate:
        _controller.value = 0;
        if (!_isStill) {
          _controller
            ..duration = _loopLength
            ..repeat();
        }
      case CandleMode.blowOut:
        if (_isStill) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _blownOut());
        } else {
          _controller
            ..duration = _blowOutLength
            ..forward(from: 0).whenComplete(_blownOut);
        }
    }
  }

  void _blownOut() {
    if (mounted) widget.onBlownOut?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => CustomPaint(
      size: const Size.square(260),
      painter: _CandlePainter(_CandleFrame.at(_controller.value, widget.mode)),
    ),
  );
}

/// The state of the flame and the smoke at one moment.
class _CandleFrame {
  const _CandleFrame({
    required this.flame,
    required this.lean,
    required this.flicker,
    this.smoke,
  });

  /// Timeline of the demonstration loop, as fractions of the loop.
  static const _gustStart = 0.45;
  static const _flameOut = 0.6;
  static const _relight = 0.88;

  /// Timeline of a single blow-out.
  static const _blowOutFlameOut = 0.4;

  factory _CandleFrame.at(double t, CandleMode mode) {
    final flicker = math.sin(t * 2 * math.pi * 7);
    return switch (mode) {
      CandleMode.demonstrate when t < _gustStart => _CandleFrame(
        flame: 1,
        lean: 0,
        flicker: flicker,
      ),
      CandleMode.demonstrate when t < _flameOut => _gust(
        (t - _gustStart) / (_flameOut - _gustStart),
        flicker,
      ),
      CandleMode.demonstrate when t < _relight => _CandleFrame(
        flame: 0,
        lean: 0,
        flicker: 0,
        smoke: (t - _flameOut) / (_relight - _flameOut),
      ),
      CandleMode.demonstrate => _CandleFrame(
        flame: Curves.easeOut.transform((t - _relight) / (1 - _relight)),
        lean: 0,
        flicker: flicker,
      ),
      CandleMode.blowOut when t < _blowOutFlameOut => _gust(
        t / _blowOutFlameOut,
        flicker,
      ),
      CandleMode.blowOut => _CandleFrame(
        flame: 0,
        lean: 0,
        flicker: 0,
        smoke: (t - _blowOutFlameOut) / (1 - _blowOutFlameOut),
      ),
    };
  }

  /// The flame leans away and shrinks as the breath reaches it.
  static _CandleFrame _gust(double u, double flicker) => _CandleFrame(
    flame: 1 - Curves.easeIn.transform(u),
    lean: Curves.easeOut.transform(u),
    flicker: flicker,
  );

  /// The size of the flame, from 0 (out) to 1 (fully lit).
  final double flame;

  /// How far the flame leans away from the breath, from 0 to 1.
  final double lean;

  /// A small wobble from -1 to 1 that makes the flame look alive.
  final double flicker;

  /// How far the smoke has risen, from 0 to 1, or null for no smoke.
  final double? smoke;
}

class _CandlePainter extends CustomPainter {
  _CandlePainter(this.frame);

  static const _wax = Color(0xFFF4E7D0);
  static const _waxShade = Color(0xFFE2CCA6);
  static const _waxTop = Color(0xFFFAF2E4);
  static const _waxOutline = Color(0xFFCDB58C);
  static const _wick = Color(0xFF3B2F2A);
  static const _outerFlame = Color(0xFFF29A38);
  static const _innerFlame = Color(0xFFFFDC73);
  static const _smoke = Color(0xFF9AA0A6);

  final _CandleFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final waxTop = size.height * 0.54;
    final waxBottom = size.height * 0.91;
    const halfWidth = 29.0;
    final wickTop = Offset(cx, waxTop - 16);

    _paintGlow(canvas, wickTop);
    _paintWax(canvas, cx, waxTop, waxBottom, halfWidth);

    canvas.drawLine(
      Offset(cx, waxTop),
      wickTop,
      Paint()
        ..color = _wick
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    if (frame.flame > 0.01) _paintFlame(canvas, wickTop);
    final smoke = frame.smoke;
    if (smoke != null) _paintSmoke(canvas, wickTop, smoke);
  }

  void _paintGlow(Canvas canvas, Offset wickTop) {
    if (frame.flame <= 0.01) return;
    final center = wickTop.translate(0, -24);
    final radius = 90 * frame.flame;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _outerFlame.withValues(alpha: 0.3 * frame.flame),
            _outerFlame.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintWax(
    Canvas canvas,
    double cx,
    double topY,
    double bottom,
    double halfWidth,
  ) {
    final body = RRect.fromRectAndCorners(
      Rect.fromLTRB(cx - halfWidth, topY, cx + halfWidth, bottom),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(body, Paint()..color = _wax);

    // A darker strip on the right side gives the candle some depth.
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTRB(cx + halfWidth * 0.45, topY, cx + halfWidth, bottom),
      Paint()..color = _waxShade,
    );
    canvas.restore();

    // The outline keeps the pale wax visible on a light background.
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _waxOutline;
    canvas.drawRRect(body, outline);

    final top = Rect.fromCenter(
      center: Offset(cx, topY),
      width: halfWidth * 2,
      height: 12,
    );
    canvas
      ..drawOval(top, Paint()..color = _waxTop)
      ..drawOval(top, outline);
  }

  void _paintFlame(Canvas canvas, Offset wickTop) {
    final base = wickTop.translate(frame.lean * 5, 5);
    final height = 64 * frame.flame;
    final width = 24 * frame.flame;
    final tip = Offset(
      base.dx + frame.lean * 34 + frame.flicker * 2,
      base.dy - height,
    );

    canvas.drawPath(_flamePath(base, tip, width), Paint()..color = _outerFlame);
    canvas.drawPath(
      _flamePath(
        base.translate(0, -2),
        Offset.lerp(base, tip, 0.6)!,
        width * 0.5,
      ),
      Paint()..color = _innerFlame,
    );
  }

  /// A teardrop from [base] to [tip] with a round bottom.
  Path _flamePath(Offset base, Offset tip, double width) {
    final height = base.dy - tip.dy;
    return Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(
        base.dx - width,
        base.dy - height * 0.25,
        tip.dx - width * 0.35,
        tip.dy + height * 0.35,
        tip.dx,
        tip.dy,
      )
      ..cubicTo(
        tip.dx + width * 0.35,
        tip.dy + height * 0.35,
        base.dx + width,
        base.dy - height * 0.25,
        base.dx,
        base.dy,
      )
      ..close();
  }

  void _paintSmoke(Canvas canvas, Offset wickTop, double progress) {
    // Three wisps rise one after another and fade as they go.
    for (var i = 0; i < 3; i++) {
      final rise = progress * 80 - i * 16;
      if (rise <= 0) continue;
      final alpha = (1 - progress) * 0.6 * (1 - i * 0.25);
      final start = wickTop.translate(0, -rise * 0.3);
      final end = wickTop.translate(0, -rise);
      final sway = 7.0 * (i.isEven ? 1 : -1);
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(
            start.dx + sway,
            start.dy - rise * 0.25,
            end.dx - sway,
            end.dy + rise * 0.25,
            end.dx,
            end.dy,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = _smoke.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.frame.flame != frame.flame ||
      oldDelegate.frame.lean != frame.lean ||
      oldDelegate.frame.flicker != frame.flicker ||
      oldDelegate.frame.smoke != frame.smoke;
}
