import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:box_breathe/clearance/clearance_routine.dart';
import 'package:box_breathe/common/int_range.dart';
import 'package:box_breathe/settings/app_settings.dart';
import 'package:box_breathe/settings/settings_controller.dart';
import 'package:box_breathe/settings/settings_store.dart';

Future<PreferencesSettingsStore> _store([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return PreferencesSettingsStore(await SharedPreferences.getInstance());
}

void main() {
  test('IntRange moves a value to the nearest permitted step', () {
    const range = IntRange(10, 60, step: 5);
    expect(range.clamp(7), 10);
    expect(range.clamp(33), 35);
    expect(range.clamp(99), 60);
    expect(range.contains(45), isTrue);
    expect(range.contains(44), isFalse);
  });

  group('PreferencesSettingsStore', () {
    test('loads the defaults when nothing is stored', () async {
      final store = await _store();
      expect(await store.load(), AppSettings.defaults);
    });

    test('saves and loads every value', () async {
      final store = await _store();
      final settings = AppSettings.defaults.copyWith(
        cueMode: CueMode.tonesAndVoice,
        toneStyle: ToneStyle.singingBowl,
        cueVolume: 0.5,
        musicEnabled: false,
        musicTrackId: 'bossa_nova',
        musicVolume: 0.25,
        breathingPhaseSeconds: 6,
        clearance: ClearanceSettings.defaults.copyWith(
          cycles: 5,
          breathingControl: const Duration(seconds: 45),
          deepBreaths: 2,
          deepBreathIn: const Duration(seconds: 5),
          deepBreathHold: const Duration(seconds: 2),
          deepBreathOut: const Duration(seconds: 6),
          huffsPerSet: 3,
        ),
      );

      await store.save(settings);

      expect(await store.load(), settings);
    });

    test('replaces missing, unknown and out-of-range values', () async {
      final store = await _store({
        'cueMode': 'loud',
        'toneStyle': 'softBeeps',
        'cueVolume': 'high',
        'musicTrackId': 'deleted_track',
        'breathingPhaseSeconds': 30,
        'clearance.cycles': 0,
        'clearance.breathingControlSeconds': 33,
      });

      final settings = await store.load();

      expect(settings.cueMode, AppSettings.defaults.cueMode);
      expect(settings.toneStyle, ToneStyle.softBeeps);
      expect(settings.cueVolume, AppSettings.defaults.cueVolume);
      expect(settings.musicTrackId, AppSettings.defaults.musicTrackId);
      expect(settings.breathingPhaseSeconds, 6);
      expect(settings.clearance.cycles, 1);
      expect(settings.clearance.breathingControl, const Duration(seconds: 35));
    });
  });

  group('SettingsController', () {
    test('saves each change and tells its listeners', () async {
      final store = MemorySettingsStore();
      final controller = SettingsController(store);
      var notified = 0;
      controller.addListener(() => notified++);

      controller.update(controller.settings.copyWith(cueMode: CueMode.voice));

      expect(notified, 1);
      expect((await store.load()).cueMode, CueMode.voice);
    });

    test('keeps values in range and ignores a change to the same value', () {
      final controller = SettingsController(MemorySettingsStore());
      var notified = 0;
      controller.addListener(() => notified++);

      controller.update(controller.settings.copyWith(breathingPhaseSeconds: 1));
      expect(controller.settings.breathingPhaseSeconds, 3);

      controller.update(controller.settings);
      expect(notified, 1);
    });

    test('restores the defaults', () async {
      final controller = SettingsController(
        MemorySettingsStore(),
        AppSettings.defaults.copyWith(musicEnabled: false),
      );
      controller.restoreDefaults();
      expect(controller.settings, AppSettings.defaults);
    });
  });
}
