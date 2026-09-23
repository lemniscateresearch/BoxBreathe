import 'package:shared_preferences/shared_preferences.dart';

import '../clearance/clearance_routine.dart';
import 'app_settings.dart';

/// Keeps the settings between app starts.
abstract interface class SettingsStore {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

/// Keeps the settings in memory only. Tests use it, and the app uses it
/// when it gets no other store.
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([this._settings = AppSettings.defaults]);

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async => _settings = settings;
}

/// Keeps the settings in the platform preferences, with one key for
/// each value. A missing or incorrect value changes to its default.
class PreferencesSettingsStore implements SettingsStore {
  PreferencesSettingsStore(this._preferences);

  static Future<PreferencesSettingsStore> open() async =>
      PreferencesSettingsStore(await SharedPreferences.getInstance());

  final SharedPreferences _preferences;

  static const _cueMode = 'cueMode';
  static const _toneStyle = 'toneStyle';
  static const _cueVolume = 'cueVolume';
  static const _musicEnabled = 'musicEnabled';
  static const _musicTrackId = 'musicTrackId';
  static const _musicVolume = 'musicVolume';
  static const _breathingPhaseSeconds = 'breathingPhaseSeconds';
  static const _cycles = 'clearance.cycles';
  static const _breathingControlSeconds = 'clearance.breathingControlSeconds';
  static const _deepBreaths = 'clearance.deepBreaths';
  static const _deepBreathInSeconds = 'clearance.deepBreathInSeconds';
  static const _deepBreathHoldSeconds = 'clearance.deepBreathHoldSeconds';
  static const _deepBreathOutSeconds = 'clearance.deepBreathOutSeconds';
  static const _huffsPerSet = 'clearance.huffsPerSet';

  @override
  Future<AppSettings> load() async {
    const d = AppSettings.defaults;
    const c = ClearanceSettings.defaults;

    T byName<T extends Enum>(String key, List<T> values, T fallback) {
      final name = _get<String>(key);
      return values.where((value) => value.name == name).firstOrNull ??
          fallback;
    }

    Duration seconds(String key, Duration fallback) =>
        Duration(seconds: _get<int>(key) ?? fallback.inSeconds);

    return AppSettings(
      cueMode: byName(_cueMode, CueMode.values, d.cueMode),
      toneStyle: byName(_toneStyle, ToneStyle.values, d.toneStyle),
      cueVolume: _get<double>(_cueVolume) ?? d.cueVolume,
      musicEnabled: _get<bool>(_musicEnabled) ?? d.musicEnabled,
      musicTrackId: _get<String>(_musicTrackId) ?? d.musicTrackId,
      musicVolume: _get<double>(_musicVolume) ?? d.musicVolume,
      breathingPhaseSeconds:
          _get<int>(_breathingPhaseSeconds) ?? d.breathingPhaseSeconds,
      clearance: ClearanceSettings(
        cycles: _get<int>(_cycles) ?? c.cycles,
        breathingControl: seconds(_breathingControlSeconds, c.breathingControl),
        deepBreaths: _get<int>(_deepBreaths) ?? c.deepBreaths,
        deepBreathIn: seconds(_deepBreathInSeconds, c.deepBreathIn),
        deepBreathHold: seconds(_deepBreathHoldSeconds, c.deepBreathHold),
        deepBreathOut: seconds(_deepBreathOutSeconds, c.deepBreathOut),
        huffsPerSet: _get<int>(_huffsPerSet) ?? c.huffsPerSet,
      ),
    ).clamped();
  }

  /// Gets the value of [key], or null when it is missing or has a
  /// different type.
  T? _get<T>(String key) {
    final value = _preferences.get(key);
    return value is T ? value : null;
  }

  @override
  Future<void> save(AppSettings settings) async {
    final c = settings.clearance;
    final p = _preferences;
    await Future.wait([
      p.setString(_cueMode, settings.cueMode.name),
      p.setString(_toneStyle, settings.toneStyle.name),
      p.setDouble(_cueVolume, settings.cueVolume),
      p.setBool(_musicEnabled, settings.musicEnabled),
      p.setString(_musicTrackId, settings.musicTrackId),
      p.setDouble(_musicVolume, settings.musicVolume),
      p.setInt(_breathingPhaseSeconds, settings.breathingPhaseSeconds),
      p.setInt(_cycles, c.cycles),
      p.setInt(_breathingControlSeconds, c.breathingControl.inSeconds),
      p.setInt(_deepBreaths, c.deepBreaths),
      p.setInt(_deepBreathInSeconds, c.deepBreathIn.inSeconds),
      p.setInt(_deepBreathHoldSeconds, c.deepBreathHold.inSeconds),
      p.setInt(_deepBreathOutSeconds, c.deepBreathOut.inSeconds),
      p.setInt(_huffsPerSet, c.huffsPerSet),
    ]);
  }
}
