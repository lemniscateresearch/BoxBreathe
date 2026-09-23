import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';

/// Renders the breathing pacer for every method to PNG files under
/// test/goldens/. Run with:
///   flutter test --update-goldens
/// The PNGs are inspected manually to verify the drawn geometry.
void main() {
  testWidgets('renders pacer goldens for every method', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    final boundaryKey = GlobalKey();

    const cases = [
      ('Box', 'goldens/box.png'),
      ('Figure eight', 'goldens/figure_eight.png'),
      ('Triangle', 'goldens/triangle.png'),
    ];

    for (final (i, entry) in cases.indexed) {
      final (label, file) = entry;
      // A unique key forces a fresh app state for every case.
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: KeyedSubtree(
            key: ValueKey('case$i'),
            child: const BoxBreatheApp(),
          ),
        ),
      );

      // Select the method in the setup sheet.
      await tester.tap(find.text('Box · 3 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Start a session and advance into the first phase so the traced
      // segment and the dot are visible. By then the setup area is gone.
      await tester.tap(find.text('Start session'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1400));

      await expectLater(find.byKey(boundaryKey), matchesGoldenFile(file));
    }
  });
}
