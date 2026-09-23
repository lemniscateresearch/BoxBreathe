import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';

/// Verifies the pacer renders in a square box: the painter's canvas must be
/// as tall as it is wide, whatever the surrounding layout constraints are.
void main() {
  testWidgets('pacer box is square under stretch constraints', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    await tester.pumpWidget(const BoxBreatheApp());

    // Start a session so the painter builds its path.
    final startButton = find.text('Start session');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();

    final painterBox =
        tester.renderObjectList<RenderBox>(
          find.byType(CustomPaint),
        ).first;
    expect(painterBox.size.width, painterBox.size.height,
        reason: 'the pacer canvas must be square');
    expect(painterBox.size.width, 260);
  });
}
