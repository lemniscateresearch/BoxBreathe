import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';

void main() {
  testWidgets('shows session options and starts a breathing session', (
    tester,
  ) async {
    await tester.pumpWidget(const BoxBreatheApp());

    expect(find.text('3:00'), findsOneWidget);

    final startButton = find.text('Start session');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();

    expect(find.text('Pause session'), findsOneWidget);
    expect(find.text('Breathe in'), findsOneWidget);
  });

  testWidgets('selects a breathing method before a session starts', (
    tester,
  ) async {
    await tester.pumpWidget(const BoxBreatheApp());

    expect(find.text('Box'), findsOneWidget);
    expect(find.text('Figure eight'), findsOneWidget);
    expect(find.text('Triangle'), findsOneWidget);

    final startButton = find.text('Start session');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();

    // While the session runs, the method selector is disabled.
    final figureEightChip = find.text('Figure eight');
    await tester.ensureVisible(figureEightChip);
    await tester.tap(figureEightChip, warnIfMissed: false);
    await tester.pump();
    expect(find.text('Trace the square. In, hold, out, hold.'), findsOneWidget);

    // After a reset, the user can select another method.
    final resetButton = find.text('Reset');
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pump();

    await tester.ensureVisible(figureEightChip);
    await tester.tap(figureEightChip);
    await tester.pumpAndSettle();

    expect(
      find.text('Trace the eight. In on one loop, out on the other.'),
      findsOneWidget,
    );

    // The figure-eight method starts with a breathe-in phase.
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();
    expect(find.text('Breathe in'), findsOneWidget);
  });

  testWidgets('opens the sidebar from the breathing page', (tester) async {
    await tester.pumpWidget(const BoxBreatheApp());

    // The breathing page is the default page.
    expect(find.text('Start session'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();

    // The drawer shows the app name and the breathing destination.
    expect(find.text('BoxBreathe'), findsOneWidget);
    expect(find.text('Breathing'), findsOneWidget);
  });
}
