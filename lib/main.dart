import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'common/audio/device_audio_services.dart';
import 'sequence/sequence_library.dart';
import 'sequence/sequence_store.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.load(
    await PreferencesSettingsStore.open(),
  );
  final sequences = await SequenceLibrary.load(
    await PreferencesSequenceStore.open(),
  );
  final audio = await DeviceAudioServices.init();
  runApp(BoxBreatheApp(settings: settings, sequences: sequences, audio: audio));
}
