import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/acknowledgements/dedication.dart';
import 'package:box_breathe/app/app.dart';
import 'package:box_breathe/common/audio/music_track.dart';

void main() {
  testWidgets('the drawer lists every page', (tester) async {
    await tester.pumpWidget(const BoxBreatheApp());
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();

    for (final label in [
      'Breathing',
      'Airway clearance',
      'Settings',
      'Acknowledgements',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('shows the dedication, every track and the licenses', (
    tester,
  ) async {
    await tester.pumpWidget(const BoxBreatheApp());
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acknowledgements'));
    await tester.pumpAndSettle();

    expect(find.text(dedicationText), findsOneWidget);
    for (final track in musicTracks) {
      expect(find.text(track.title), findsOneWidget, reason: track.title);
      expect(find.text(track.sourceUrl), findsOneWidget);
    }

    final licenses = find.text('Open-source licenses');
    await tester.ensureVisible(licenses);
    await tester.tap(licenses);
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
