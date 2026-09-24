import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'exercise_sequence.dart';

/// Keeps the user's sequences between app starts. The sequences have a
/// store of their own, so that "Restore defaults" on the settings page
/// does not delete them.
abstract interface class SequenceStore {
  Future<List<ExerciseSequence>> load();
  Future<void> save(List<ExerciseSequence> sequences);
}

/// Keeps the sequences in memory only. Tests use it, and the app uses it
/// when it gets no other store.
class MemorySequenceStore implements SequenceStore {
  MemorySequenceStore([this._sequences = const []]);

  List<ExerciseSequence> _sequences;

  @override
  Future<List<ExerciseSequence>> load() async => _sequences;

  @override
  Future<void> save(List<ExerciseSequence> sequences) async =>
      _sequences = sequences;
}

/// Keeps the sequences in the platform preferences, as one JSON value.
/// Data that it cannot read gives an empty list, and a segment that it
/// does not know is left out.
class PreferencesSequenceStore implements SequenceStore {
  PreferencesSequenceStore(this._preferences);

  static Future<PreferencesSequenceStore> open() async =>
      PreferencesSequenceStore(await SharedPreferences.getInstance());

  final SharedPreferences _preferences;

  static const _key = 'sequences';
  static const _version = 1;

  @override
  Future<List<ExerciseSequence>> load() async => decode(_preferences.get(_key));

  @override
  Future<void> save(List<ExerciseSequence> sequences) =>
      _preferences.setString(_key, encode(sequences));

  static String encode(List<ExerciseSequence> sequences) => jsonEncode({
    'version': _version,
    'sequences': [for (final sequence in sequences) sequence.toJson()],
  });

  static List<ExerciseSequence> decode(Object? value) {
    if (value is! String) return const [];
    final Object? json;
    try {
      json = jsonDecode(value);
    } on FormatException {
      return const [];
    }
    if (json is! Map || json['sequences'] is! List) return const [];
    return [
      for (final sequence in (json['sequences'] as List).map(
        ExerciseSequence.fromJson,
      ))
        ?sequence,
    ];
  }
}
