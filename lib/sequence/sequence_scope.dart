import 'package:flutter/widgets.dart';

import 'sequence_library.dart';

/// Gives the [SequenceLibrary] to the widgets below it.
class SequenceScope extends InheritedNotifier<SequenceLibrary> {
  const SequenceScope({
    super.key,
    required SequenceLibrary library,
    required super.child,
  }) : super(notifier: library);

  /// The library. The widget rebuilds when a sequence changes.
  static SequenceLibrary of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SequenceScope>()!.notifier!;

  /// The library, without a rebuild when a sequence changes.
  static SequenceLibrary read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SequenceScope>()!.notifier!;
}
