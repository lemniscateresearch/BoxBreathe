import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';

void main() {
  testWidgets('shows session options and starts a breathing session', (
    tester,
  ) async {
    await tester.pumpWidget(const BoxBreatheApp());

    // 3 min of box breathing is 11 whole breaths, which take 2:56.
    expect(find.text('11 breaths, about 3 min.'), findsOneWidget);

    await tester.tap(find.text('Start session'));
    await tester.pump();

    expect(find.text('Pause session'), findsOneWidget);
    expect(find.text('Breathe in'), findsOneWidget);
  });

  testWidgets('counts down the breaths that remain', (tester) async {
    await tester.pumpWidget(const BoxBreatheApp());
    await tester.tap(find.text('Start session'));
    await tester.pump();

    // One box breath is 4 phases of 4 s. Short frames, so each phase that
    // runs out moves on at once.
    expect(find.text('11 breaths, about 3 min.'), findsOneWidget);
    for (var i = 0; i < 165; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('10 breaths, about 3 min.'), findsOneWidget);

    await tester.tap(find.text('Pause session'));
    await tester.pump();
  });

  testWidgets('selects a breathing method in the setup sheet', (tester) async {
    await tester.pumpWidget(const BoxBreatheApp());

    await tester.tap(find.text('Box · 3 min'));
    await tester.pumpAndSettle();

    expect(find.text('Box'), findsOneWidget);
    expect(find.text('Figure eight'), findsOneWidget);
    expect(find.text('Triangle'), findsOneWidget);

    await tester.tap(find.text('Figure eight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Figure eight · 3 min'), findsOneWidget);
    expect(
      find.text('Trace the eight. In on one loop, out on the other.'),
      findsOneWidget,
    );

    // The figure-eight method starts with a breathe-in phase.
    await tester.tap(find.text('Start session'));
    await tester.pump();
    expect(find.text('Breathe in'), findsOneWidget);
  });

  testWidgets('hides the setup while a session runs', (tester) async {
    await tester.pumpWidget(const BoxBreatheApp());

    await tester.tap(find.text('Start session'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Box · 3 min'), findsNothing);

    // After a reset, the setup comes back.
    await tester.tap(find.byTooltip('Reset'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Box · 3 min'), findsOneWidget);
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

  testWidgets('opens the airway clearance page and starts ACBT', (
    tester,
  ) async {
    await tester.pumpWidget(const BoxBreatheApp());

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Airway clearance'));
    await tester.pumpAndSettle();

    // ACBT is the default routine. The setup sheet shows both routines.
    await tester.tap(find.text('Full cycle (ACBT)'));
    await tester.pumpAndSettle();
    expect(find.text('Huffs with rests'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final startButton = find.text('Start session');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();

    // The session starts with relaxed breathing in the first cycle.
    expect(find.text('Relaxed breathing'), findsOneWidget);
    expect(find.text('Cycle 1 of 3'), findsOneWidget);
    expect(find.text('Pause session'), findsOneWidget);
  });
}
