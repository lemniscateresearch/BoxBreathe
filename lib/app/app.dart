import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import '../settings/settings_scope.dart';
import '../settings/settings_store.dart';
import 'app_shell.dart';
import 'theme.dart';

class BoxBreatheApp extends StatefulWidget {
  /// Without [settings], the app keeps its settings in memory only.
  const BoxBreatheApp({super.key, this.settings});

  final SettingsController? settings;

  @override
  State<BoxBreatheApp> createState() => _BoxBreatheAppState();
}

class _BoxBreatheAppState extends State<BoxBreatheApp> {
  late final _settings =
      widget.settings ?? SettingsController(MemorySettingsStore());

  @override
  void dispose() {
    // Dispose the controller only when this state made it.
    if (widget.settings == null) _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsScope(
    controller: _settings,
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
  );
}
