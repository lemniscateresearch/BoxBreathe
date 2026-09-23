import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/clearance/clearance_step.dart';
import 'package:box_breathe/clearance/widgets/candle_visual.dart';
import 'package:box_breathe/clearance/widgets/clearance_visual.dart';

Widget _wrap(Widget child, {bool reduceMotion = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduceMotion),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

const _huff = ClearanceStep(
  kind: ClearanceStepKind.huff,
  duration: null,
  cycle: 1,
);
const _rest = ClearanceStep(
  kind: ClearanceStepKind.breathingControl,
  duration: Duration(seconds: 30),
  cycle: 1,
);

void main() {
  group('CandleVisual', () {
    testWidgets('loops the demonstration', (tester) async {
      await tester.pumpWidget(_wrap(const CandleVisual()));
      await tester.pump(const Duration(seconds: 5));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('stays still when the platform asks for reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CandleVisual(), reduceMotion: true));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reports the end of a blow-out', (tester) async {
      var blownOut = false;
      await tester.pumpWidget(
        _wrap(
          CandleVisual(
            mode: CandleMode.blowOut,
            onBlownOut: () => blownOut = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(blownOut, isFalse);
      await tester.pump(const Duration(milliseconds: 400));
      expect(blownOut, isTrue);
    });

    testWidgets('ends a blow-out at once with reduced motion', (tester) async {
      var blownOut = false;
      await tester.pumpWidget(
        _wrap(
          CandleVisual(
            mode: CandleMode.blowOut,
            onBlownOut: () => blownOut = true,
          ),
          reduceMotion: true,
        ),
      );
      await tester.pump();
      expect(blownOut, isTrue);
    });
  });

  group('ClearanceVisual', () {
    Widget visual(ClearanceStep step, {required bool isRunning}) => _wrap(
      ClearanceVisual(
        animation: const AlwaysStoppedAnimation(0),
        step: step,
        isRunning: isRunning,
        isFinished: false,
      ),
    );

    testWidgets('blows the candle out when the user finishes a huff', (
      tester,
    ) async {
      await tester.pumpWidget(visual(_huff, isRunning: true));
      expect(find.byType(CandleVisual), findsOneWidget);

      await tester.pumpWidget(visual(_rest, isRunning: true));
      final candle = tester.widget<CandleVisual>(find.byType(CandleVisual));
      expect(candle.mode, CandleMode.blowOut);

      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byType(CandleVisual), findsNothing);
    });

    testWidgets('removes the candle at once after a reset', (tester) async {
      await tester.pumpWidget(visual(_huff, isRunning: true));
      await tester.pumpWidget(visual(_rest, isRunning: false));
      expect(find.byType(CandleVisual), findsNothing);
    });
  });
}
