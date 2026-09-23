import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_settings.dart';
import 'settings_store.dart';

/// Holds the current settings. Each change goes to the store at once.
class SettingsController extends ChangeNotifier {
  SettingsController(this._store, [this._settings = AppSettings.defaults]);

  static Future<SettingsController> load(SettingsStore store) async =>
      SettingsController(store, await store.load());

  final SettingsStore _store;
  AppSettings _settings;

  AppSettings get settings => _settings;

  void update(AppSettings settings) {
    final next = settings.clamped();
    if (next == _settings) return;
    _settings = next;
    notifyListeners();
    unawaited(_store.save(next));
  }

  void restoreDefaults() => update(AppSettings.defaults);
}
