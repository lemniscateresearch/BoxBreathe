import 'package:flutter/widgets.dart';

import 'audio_services.dart';

/// Gives the [AudioServices] to the widgets below it.
class AudioScope extends InheritedWidget {
  const AudioScope({super.key, required this.services, required super.child});

  final AudioServices services;

  static AudioServices of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AudioScope>()!.services;

  @override
  bool updateShouldNotify(AudioScope oldWidget) =>
      services != oldWidget.services;
}
