import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.load(
    await PreferencesSettingsStore.open(),
  );
  runApp(BoxBreatheApp(settings: settings));
}
