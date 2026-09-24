import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:box_breathe/breathing/breathing_method.dart';
import 'package:box_breathe/clearance/clearance_routine.dart';
import 'package:box_breathe/sequence/exercise_sequence.dart';
import 'package:box_breathe/sequence/sequence_library.dart';
import 'package:box_breathe/sequence/sequence_segment.dart';
import 'package:box_breathe/sequence/sequence_store.dart';

const _morning = ExerciseSequence(
  id: 'm',
  name: 'Morning',
  segments: [
    BreathingSegment(BreathingMethod.box, breaths: 6),
    ClearanceSegment(ClearanceRoutine.acbt),
    BreathingSegment(BreathingMethod.triangle, breaths: 8),
  ],
);

Future<PreferencesSequenceStore> _store([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return PreferencesSequenceStore(await SharedPreferences.getInstance());
}

void main() {
  group('PreferencesSequenceStore', () {
    test('loads an empty list when nothing is saved', () async {
      expect(await (await _store()).load(), isEmpty);
    });

    test('keeps sequences between loads', () async {
      final store = await _store();
      await store.save([_morning]);
      expect(await store.load(), [_morning]);
    });

    test('loads an empty list from data that is not JSON', () async {
      final store = await _store({'sequences': 'not json {'});
      expect(await store.load(), isEmpty);
    });

    test('leaves out unknown segments and fixes bad counts', () async {
      final store = await _store({
        'sequences': jsonEncode({
          'version': 1,
          'sequences': [
            {
              'id': 'x',
              'name': 'Mixed',
              'segments': [
                {'kind': 'breathing', 'name': 'box', 'breaths': 500},
                {'kind': 'humming', 'name': 'bee'},
                {'kind': 'clearance', 'name': 'unknown'},
              ],
            },
            {'name': 'No id'},
          ],
        }),
      });

      final loaded = await store.load();
      expect(loaded, hasLength(1));
      expect(loaded.single.segments, [
        BreathingSegment(
          BreathingMethod.box,
          breaths: BreathingSegment.breathsRange.max,
        ),
      ]);
    });
  });

  group('SequenceLibrary', () {
    test(
      'creates, updates and removes sequences, and saves each change',
      () async {
        final store = MemorySequenceStore();
        final library = SequenceLibrary(store);
        var changes = 0;
        library.addListener(() => changes++);

        final created = library.create();
        expect(library.sequences, [created]);
        expect(created.name, 'Sequence 1');

        final edited = created.copyWith(segments: _morning.segments);
        library.update(edited);
        expect(library.byId(created.id), edited);
        expect(await store.load(), [edited]);

        // An update that changes nothing does not notify.
        library.update(edited);
        expect(changes, 2);

        library.remove(created.id);
        expect(library.sequences, isEmpty);
        expect(await store.load(), isEmpty);
      },
    );
  });
}
