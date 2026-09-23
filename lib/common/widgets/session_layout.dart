import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The layout of an exercise page. The visual takes the space that the
/// other parts leave, so the page fits on one screen. The setup area
/// slides away while a session runs and comes back when it stops.
///
/// If the other parts leave less than [minVisualSize], for example on a
/// short screen or with large text, the page scrolls.
class SessionLayout extends StatelessWidget {
  const SessionLayout({
    super.key,
    required this.visual,
    required this.prompt,
    required this.details,
    required this.setup,
    required this.showSetup,
    required this.controls,
  });

  /// The smallest and largest sizes of the square visual.
  static const minVisualSize = 140.0;
  static const maxVisualSize = 320.0;

  static const _setupDuration = Duration(milliseconds: 300);

  /// A square widget that is drawn for a 260 px square. It is scaled to
  /// fit the space that is available.
  final Widget visual;
  final Widget prompt;
  final Widget details;
  final Widget setup;
  final bool showSetup;
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _setupDuration;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          // The column is as tall as the screen, or as tall as its
          // content with the smallest visual, whichever is taller.
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FixedIntrinsicHeight(
                    height: minVisualSize,
                    child: LayoutBuilder(
                      builder: (context, space) {
                        final side = math.min(
                          maxVisualSize,
                          math.min(space.maxWidth, space.maxHeight),
                        );
                        return Center(
                          child: SizedBox.square(
                            dimension: side,
                            child: FittedBox(child: visual),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                prompt,
                const SizedBox(height: 12),
                details,
                AnimatedSwitcher(
                  duration: duration,
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) => SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.topCenter,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: showSetup
                      ? Padding(
                          key: const ValueKey('setup'),
                          padding: const EdgeInsets.only(top: 20),
                          child: setup,
                        )
                      : const SizedBox(
                          key: ValueKey('none'),
                          width: double.infinity,
                        ),
                ),
                const SizedBox(height: 20),
                controls,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reports a fixed intrinsic height, so that [IntrinsicHeight] can
/// measure the column without asking the [LayoutBuilder] inside.
class _FixedIntrinsicHeight extends SingleChildRenderObjectWidget {
  const _FixedIntrinsicHeight({required this.height, super.child});

  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFixedIntrinsicHeight(height);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFixedIntrinsicHeight renderObject,
  ) => renderObject.height = height;
}

class _RenderFixedIntrinsicHeight extends RenderProxyBox {
  _RenderFixedIntrinsicHeight(this._height);

  double _height;

  set height(double value) {
    if (value == _height) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicHeight(double width) => _height;

  @override
  double computeMaxIntrinsicHeight(double width) => _height;

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;
}
