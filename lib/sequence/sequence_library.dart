import 'dart:async';

import 'package:flutter/foundation.dart';

import 'exercise_sequence.dart';
import 'sequence_store.dart';

/// Holds the user's sequences. Each change goes to the store at once.
class SequenceLibrary extends ChangeNotifier {
  SequenceLibrary(this._store, [this._sequences = const []]);

  static Future<SequenceLibrary> load(SequenceStore store) async =>
      SequenceLibrary(store, await store.load());

  final SequenceStore _store;
  List<ExerciseSequence> _sequences;

  List<ExerciseSequence> get sequences => _sequences;

  ExerciseSequence? byId(String? id) =>
      _sequences.where((sequence) => sequence.id == id).firstOrNull;

  /// Adds an empty sequence at the end of the list and returns it.
  ExerciseSequence create() {
    final sequence = ExerciseSequence(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: 'Sequence ${_sequences.length + 1}',
    );
    _change([..._sequences, sequence]);
    return sequence;
  }

  /// Replaces the sequence that has the same id as [sequence].
  void update(ExerciseSequence sequence) => _change([
    for (final old in _sequences) old.id == sequence.id ? sequence : old,
  ]);

  void remove(String id) =>
      _change([..._sequences.where((sequence) => sequence.id != id)]);

  void _change(List<ExerciseSequence> sequences) {
    if (listEquals(sequences, _sequences)) return;
    _sequences = List.unmodifiable(sequences);
    notifyListeners();
    unawaited(_store.save(_sequences));
  }
}
