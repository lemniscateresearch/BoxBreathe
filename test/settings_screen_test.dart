import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';
import 'package:box_breathe/settings/app_settings.dart';
import 'package:box_breathe/settings/settings_controller.dart';
import 'package:box_breathe/settings/settings_store.dart';

Future<void> _openPage(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open navigation'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  late MemorySettingsStore store;
  late SettingsController controller;

  setUp(() {
    store = MemorySettingsStore();
    controller = SettingsController(store);
  });

  testWidgets('changes and saves a setting', (tester) async {
    await tester.pumpWidget(BoxBreatheApp(settings: controller));
    await _openPage(tester, 'Settings');

    await _tap(tester, find.byTooltip('Increase Seconds per phase'));
    await _tap(tester, find.text('Bossa Nova'));
    await _tap(tester, find.text('Voice'));

    expect(controller.settings.breathingPhaseSeconds, 5);
    expect(controller.settings.musicTrackId, 'bossa_nova');
    expect(controller.settings.cueMode, CueMode.voice);
    expect((await store.load()).breathingPhaseSeconds, 5);
  });

  testWidgets('the next breathing session uses the new pace', (tester) async {
    controller.update(AppSettings.defaults.copyWith(breathingPhaseSeconds: 6));
    await tester.pumpWidget(BoxBreatheApp(settings: controller));

    final start = find.text('Start session');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 5000));

    // With 4-second phases, the hold would start at 4 seconds.
    expect(find.text('Breathe in'), findsOneWidget);
    expect(find.text('Hold'), findsNothing);
  });

  testWidgets('restores the defaults after a confirmation', (tester) async {
    controller.update(AppSettings.defaults.copyWith(musicEnabled: false));
    await tester.pumpWidget(BoxBreatheApp(settings: controller));
    await _openPage(tester, 'Settings');

    await _tap(tester, find.text('Restore default settings'));
    expect(find.text('Restore the default settings?'), findsOneWidget);
    await _tap(tester, find.widgetWithText(FilledButton, 'Restore'));

    expect(controller.settings, AppSettings.defaults);
  });
}
