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

  /// Adds an empty sequence at the end of the list and returns it. Its
  /// name is "Sequence N", with the lowest N that no sequence uses.
  ExerciseSequence create() {
    final names = {for (final sequence in _sequences) sequence.name};
    var number = 1;
    while (names.contains('Sequence $number')) {
      number++;
    }
    // The clock can give the same time twice, so step past used ids.
    var id = DateTime.now().microsecondsSinceEpoch;
    while (byId('$id') != null) {
      id++;
    }
    final sequence = ExerciseSequence(id: '$id', name: 'Sequence $number');
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
