import 'package:flutter/material.dart';

const _seedColor = Color(0xFF163C34);

/// The light color scheme when the platform supplies no dynamic colors.
final fallbackLightScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  surface: const Color(0xFFF6F8F6),
);

/// The dark color scheme when the platform supplies no dynamic colors.
final fallbackDarkScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.dark,
);

ThemeData buildTheme(ColorScheme colorScheme) => ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.surface,
  textTheme: ThemeData(brightness: colorScheme.brightness).textTheme.apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  ),
);
