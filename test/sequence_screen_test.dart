import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/app/app.dart';
import 'package:box_breathe/breathing/breathing_method.dart';
import 'package:box_breathe/clearance/clearance_routine.dart';
import 'package:box_breathe/sequence/exercise_sequence.dart';
import 'package:box_breathe/sequence/sequence_library.dart';
import 'package:box_breathe/sequence/sequence_segment.dart';
import 'package:box_breathe/sequence/sequence_store.dart';

void main() {
  late SequenceLibrary library;

  Future<void> openSequencesPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(BoxBreatheApp(sequences: library));
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sequences'));
    await tester.pumpAndSettle();
  }

  List<SequenceSegment> segments() => library.sequences.single.segments;

  /// Lets time pass in short frames. A step moves on only at a frame, so
  /// one long pump would move on by one step only.
  Future<void> wait(WidgetTester tester, Duration duration) async {
    const frame = Duration(milliseconds: 250);
    for (var t = Duration.zero; t < duration; t += frame) {
      await tester.pump(frame);
    }
  }

  testWidgets('the user creates and edits a sequence', (tester) async {
    library = SequenceLibrary(MemorySequenceStore());
    await openSequencesPage(tester);

    expect(find.text('Your own sequence'), findsOneWidget);
    await tester.tap(find.text('Create a sequence'));
    await tester.pumpAndSettle();
    expect(find.text('Edit sequence'), findsOneWidget);
    expect(find.text('Add a part to begin.'), findsOneWidget);

    Future<void> addPart(String title) async {
      await tester.tap(find.text('Add a part'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
    }

    await addPart('Box breathing');
    await addPart('Huffs with rests');
    expect(segments(), [
      const BreathingSegment(BreathingMethod.box),
      const ClearanceSegment(ClearanceRoutine.huffsWithRests),
    ]);
    // A clearance part brings the safety note.
    expect(find.textContaining('physiotherapist'), findsOneWidget);

    await tester.tap(find.byTooltip('Move part 2 up'));
    await tester.pumpAndSettle();
    expect(segments().first, isA<ClearanceSegment>());

    await tester.tap(find.byTooltip('Increase Breaths'));
    await tester.pumpAndSettle();
    expect(
      segments().last,
      const BreathingSegment(BreathingMethod.box, breaths: 6),
    );

    await tester.tap(find.byTooltip('Remove part 1'));
    await tester.pumpAndSettle();
    expect(segments(), [
      const BreathingSegment(BreathingMethod.box, breaths: 6),
    ]);

    await tester.enterText(find.byType(TextField), 'Morning');
    await tester.pumpAndSettle();
    expect(library.sequences.single.name, 'Morning');

    // Back on the page, the edited sequence is ready to play.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Morning · 1 part'), findsOneWidget);
    expect(find.text('Breathe in'), findsOneWidget);
  });

  testWidgets('the editor fits at 2× text', (tester) async {
    library = SequenceLibrary(MemorySequenceStore(), const [
      ExerciseSequence(
        id: 'a',
        name: 'A long name for a sequence',
        segments: [
          BreathingSegment(BreathingMethod.figureEight, breaths: 30),
          ClearanceSegment(ClearanceRoutine.huffsWithRests),
        ],
      ),
    ]);
    const size = Size(360, 780);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(2),
        ),
        child: BoxBreatheApp(sequences: library),
      ),
    );
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sequences'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('2 parts'));
    await tester.tap(find.textContaining('2 parts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit this sequence'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Edit sequence'), findsOneWidget);
  });

  testWidgets('the user deletes a sequence', (tester) async {
    library = SequenceLibrary(MemorySequenceStore(), const [
      ExerciseSequence(
        id: 'a',
        name: 'Evening',
        segments: [BreathingSegment(BreathingMethod.triangle)],
      ),
    ]);
    await openSequencesPage(tester);

    await tester.tap(find.text('Evening · 1 part'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit this sequence'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete sequence'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(library.sequences, isEmpty);
    expect(find.text('Edit sequence'), findsNothing);
  });

  testWidgets('a session shows the part and waits for Done at a huff', (
    tester,
  ) async {
    library = SequenceLibrary(MemorySequenceStore(), const [
      ExerciseSequence(
        id: 'a',
        name: 'Clear',
        segments: [
          BreathingSegment(BreathingMethod.box, breaths: 1),
          ClearanceSegment(ClearanceRoutine.huffsWithRests),
        ],
      ),
    ]);
    await openSequencesPage(tester);

    await tester.tap(find.text('Start session'));
    await tester.pump();
    expect(find.text('Part 1 of 2 · Breath 1 of 1'), findsOneWidget);

    // One box breath of 4 × 4 s, then the 5-second transition. Each step
    // can end up to one frame late, so wait a little longer.
    await wait(tester, const Duration(seconds: 18));
    expect(find.text('Get ready'), findsOneWidget);
    expect(find.text('Part 2 of 2 · Up next'), findsOneWidget);

    // The rest of the transition, the default 30-second rest, then the huff.
    await wait(tester, const Duration(seconds: 36));
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(find.text('Pause session'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset'));
    await tester.pumpAndSettle();
  });
}
