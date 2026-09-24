import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/breathing/widgets/session_clock.dart';

Future<void> _pumpClock(
  WidgetTester tester, {
  required int seconds,
  int breaths = 11,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SessionClock(secondsRemaining: seconds, breathsRemaining: breaths),
    ),
  ),
);

void main() {
  // Seconds left → the minutes shown, always rounded up.
  for (final (seconds, minutes) in const [
    (176, 3),
    (121, 3),
    (120, 2),
    (61, 2),
    (60, 1),
    (1, 1),
  ]) {
    testWidgets('$seconds s left shows about $minutes min', (tester) async {
      await _pumpClock(tester, seconds: seconds);
      expect(find.text('11 breaths, about $minutes min.'), findsOneWidget);
    });
  }

  testWidgets('shows the number of breaths it is given', (tester) async {
    await _pumpClock(tester, seconds: 90, breaths: 7);
    expect(find.text('7 breaths, about 2 min.'), findsOneWidget);
  });

  testWidgets('is a live region with a label for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpClock(tester, seconds: 176);

    final node = tester.getSemantics(find.byType(SessionClock));
    expect(node.label, contains('11 breaths, about 3 min.'));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    semantics.dispose();
  });
}
