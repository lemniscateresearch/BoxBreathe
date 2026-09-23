import 'package:flutter/widgets.dart';

import 'settings_controller.dart';

/// Gives the [SettingsController] to the widgets below it.
class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The controller. The widget rebuilds when a setting changes.
  static SettingsController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;

  /// The controller, without a rebuild when a setting changes. Use this
  /// to read the settings once, for example when a session starts.
  static SettingsController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}
