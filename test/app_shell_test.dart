import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';

void main() {
  testWidgets('the sidebar shows every page without overflow at 2× text', (
    tester,
  ) async {
    const size = Size(412, 915);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(2)),
        child: BoxBreatheApp(),
      ),
    );

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final label in const [
      'Breathing',
      'Airway clearance',
      'Settings',
      'Acknowledgements',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    // A tap on a destination opens its page and closes the sidebar.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Sound cues'), findsOneWidget);
    expect(find.text('Acknowledgements'), findsNothing);
  });
}
