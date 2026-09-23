import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/main.dart';

void main() {
  testWidgets('shows session options and starts a breathing session', (
    tester,
  ) async {
    await tester.pumpWidget(const BoxBreatheApp());

    expect(find.text('BoxBreathe'), findsOneWidget);
    expect(find.text('1 min'), findsOneWidget);
    expect(find.text('3 min'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('3:00'), findsOneWidget);

    final startButton = find.text('Start session');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();

    expect(find.text('Pause session'), findsOneWidget);
    expect(find.text('Breathe in'), findsOneWidget);
  });
}
