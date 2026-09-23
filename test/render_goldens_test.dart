import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/main.dart';

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

      final chip = find.text(label);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();

      // Start a session and advance into the first phase so the traced
      // segment and the dot are visible.
      final startButton = find.text('Start session');
      await tester.ensureVisible(startButton);
      await tester.tap(startButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1400));

      // Scroll back to the top so the whole pacer is inside the capture.
      await tester.ensureVisible(find.text('BoxBreathe'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile(file),
      );
    }
  });
}
