import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../common/audio/audio_scope.dart';
import '../common/audio/audio_services.dart';
import '../sequence/sequence_library.dart';
import '../sequence/sequence_scope.dart';
import '../sequence/sequence_store.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_scope.dart';
import '../settings/settings_store.dart';
import 'app_shell.dart';
import 'theme.dart';

class BoxBreatheApp extends StatefulWidget {
  /// Without [settings] or [sequences], the app keeps them in memory
  /// only. Without [audio], the app is silent. The tests use these
  /// defaults.
  const BoxBreatheApp({
    super.key,
    this.settings,
    this.sequences,
    this.audio = const SilentAudioServices(),
  });

  final SettingsController? settings;
  final SequenceLibrary? sequences;
  final AudioServices audio;

  @override
  State<BoxBreatheApp> createState() => _BoxBreatheAppState();
}

class _BoxBreatheAppState extends State<BoxBreatheApp> {
  late final _settings =
      widget.settings ?? SettingsController(MemorySettingsStore());
  late final _sequences =
      widget.sequences ?? SequenceLibrary(MemorySequenceStore());

  @override
  void dispose() {
    // Dispose the controllers only when this state made them.
    if (widget.settings == null) _settings.dispose();
    if (widget.sequences == null) _sequences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsScope(
    controller: _settings,
    child: SequenceScope(
      library: _sequences,
      child: AudioScope(
        services: widget.audio,
        child: DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) => MaterialApp(
            title: 'BoxBreathe',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(lightDynamic ?? fallbackLightScheme),
            darkTheme: buildTheme(darkDynamic ?? fallbackDarkScheme),
            themeMode: ThemeMode.system,
            home: const AppShell(),
          ),
        ),
      ),
    ),
  );
}
