import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'theme.dart';

class BoxBreatheApp extends StatelessWidget {
  const BoxBreatheApp({super.key});

  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
    builder: (lightDynamic, darkDynamic) => MaterialApp(
      title: 'BoxBreathe',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(lightDynamic ?? fallbackLightScheme),
      darkTheme: buildTheme(darkDynamic ?? fallbackDarkScheme),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    ),
  );
}
