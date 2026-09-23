import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';

/// Opens the airway clearance page from the sidebar.
Future<void> _openClearance(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Airway clearance'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('both exercise pages fit on a tall phone', (tester) async {
    const size = Size(412, 915);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const BoxBreatheApp());

    void expectStartOnScreen() {
      final start = tester.getRect(find.text('Start session'));
      expect(start.bottom, lessThanOrEqualTo(size.height));
    }

    expectStartOnScreen();
    await _openClearance(tester);
    expectStartOnScreen();
  });

  // The test font is wider than a real font, so these pages scroll here.
  // The layout must scroll instead of overflow.
  for (final (label, size, textScale) in const [
    ('a small phone', Size(360, 640), 1.0),
    ('large text', Size(412, 915), 2.0),
  ]) {
    testWidgets('both exercise pages scroll without overflow with $label', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Only the pages get the text scale, because the drawer is not
      // part of this layout.
      Widget app(double scale) => MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
        child: const BoxBreatheApp(),
      );

      Future<void> expectNoOverflow() async {
        await tester.pumpWidget(app(textScale));
        await tester.ensureVisible(find.text('Start session'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(app(1));
      }

      await tester.pumpWidget(app(1));
      await expectNoOverflow();
      await _openClearance(tester);
      await expectNoOverflow();
    });
  }
}
