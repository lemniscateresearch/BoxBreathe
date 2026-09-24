import 'package:flutter/material.dart';

import '../breathing/breathing_method.dart';
import '../clearance/clearance_routine.dart';
import '../common/widgets/number_stepper.dart';
import '../common/widgets/safety_note.dart';
import '../settings/settings_scope.dart';
import 'exercise_sequence.dart';
import 'sequence_scope.dart';
import 'sequence_segment.dart';
import 'sequence_timeline.dart';

/// Edits one sequence: its name, and its parts and their order. Each
/// change is saved at once, as on the settings page.
///
/// The user can drag a part by its handle, or use the Move up and Move
/// down buttons, which are easier to use for some people.
class SequenceEditorScreen extends StatefulWidget {
  const SequenceEditorScreen({super.key, required this.sequenceId});

  final String sequenceId;

  @override
  State<SequenceEditorScreen> createState() => _SequenceEditorScreenState();
}

class _SequenceEditorScreenState extends State<SequenceEditorScreen> {
  late final TextEditingController _name;

  /// The sequence as it was at the last build. After a delete, the page
  /// shows it while it closes.
  ExerciseSequence? _last;

  @override
  void initState() {
    super.initState();
    final sequence = SequenceScope.read(context).byId(widget.sequenceId);
    _name = TextEditingController(text: sequence?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = SequenceScope.of(context);
    final sequence = _last = library.byId(widget.sequenceId) ?? _last;
    if (sequence == null) return const Scaffold();

    void update(List<SequenceSegment> segments) =>
        library.update(sequence.copyWith(segments: segments));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit sequence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete sequence',
            onPressed: () => _confirmDelete(context, sequence),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              buildDefaultDragHandles: false,
              header: _Header(
                controller: _name,
                onChanged: (name) =>
                    library.update(sequence.copyWith(name: name)),
              ),
              footer: _Footer(
                sequence: sequence,
                onAdd: sequence.canAddSegment
                    ? () => _openAddSheet(context, sequence)
                    : null,
              ),
              itemCount: sequence.segments.length,
              onReorderItem: (from, to) {
                final segments = [...sequence.segments];
                segments.insert(to, segments.removeAt(from));
                update(segments);
              },
              itemBuilder: (context, index) => _PartCard(
                key: ValueKey(index),
                index: index,
                count: sequence.segments.length,
                segment: sequence.segments[index],
                onChanged: (segment) =>
                    update([...sequence.segments]..[index] = segment),
                onMove: (offset) {
                  final segments = [...sequence.segments];
                  segments.insert(index + offset, segments.removeAt(index));
                  update(segments);
                },
                onRemove: () => update([...sequence.segments]..removeAt(index)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExerciseSequence sequence,
  ) async {
    final library = SequenceScope.read(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${sequence.displayName}?'),
        content: const Text('This removes the sequence and all its parts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    navigator.pop();
    library.remove(sequence.id);
  }

  void _openAddSheet(BuildContext context, ExerciseSequence sequence) {
    final library = SequenceScope.read(context);
    void add(SequenceSegment segment) {
      library.update(
        sequence.copyWith(segments: [...sequence.segments, segment]),
      );
      Navigator.of(context).pop();
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHeading('Breathing shapes'),
              for (final method in BreathingMethod.values)
                ListTile(
                  leading: const Icon(Icons.self_improvement_rounded),
                  title: Text(BreathingSegment(method).title),
                  subtitle: Text(method.description),
                  onTap: () => add(BreathingSegment(method)),
                ),
              const _SheetHeading('Airway clearance'),
              for (final routine in ClearanceRoutine.values)
                ListTile(
                  leading: const Icon(Icons.air_rounded),
                  title: Text(routine.label),
                  subtitle: Text(routine.description),
                  onTap: () => add(ClearanceSegment(routine)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 16),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: ExerciseSequence.maxNameLength,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
      ),
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.sequence, required this.onAdd});

  final ExerciseSequence sequence;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context).settings;
    final steps = buildTimeline(
      sequence,
      phaseLength: Duration(seconds: settings.breathingPhaseSeconds),
      clearance: settings.clearance,
    );
    final mutedStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        if (sequence.segments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Add a part to begin.',
              textAlign: TextAlign.center,
              style: mutedStyle,
            ),
          ),
        FilledButton.tonalIcon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            onAdd == null
                ? 'At most ${ExerciseSequence.maxSegments} parts'
                : 'Add a part',
          ),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
        if (sequence.segments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            lengthLabel(steps),
            textAlign: TextAlign.center,
            style: mutedStyle,
          ),
        ],
        if (sequence.hasClearance) ...[
          const SizedBox(height: 12),
          const SafetyNote(),
        ],
      ],
    );
  }
}

/// One part of the sequence, with its controls. The controls sit on
/// their own row, so the card still fits with large text.
class _PartCard extends StatelessWidget {
  const _PartCard({
    super.key,
    required this.index,
    required this.count,
    required this.segment,
    required this.onChanged,
    required this.onMove,
    required this.onRemove,
  });

  final int index;
  final int count;
  final SequenceSegment segment;
  final ValueChanged<SequenceSegment> onChanged;

  /// Moves the part by -1 (up) or 1 (down).
  final ValueChanged<int> onMove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final part = 'part ${index + 1}';
    final segment = this.segment;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${index + 1}. ${segment.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Tooltip(
                    message: 'Drag to move $part',
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.drag_handle_rounded),
                    ),
                  ),
                ),
              ],
            ),
            if (segment is BreathingSegment)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: NumberStepper(
                  label: 'Breaths',
                  value: segment.breaths,
                  range: BreathingSegment.breathsRange,
                  onChanged: (breaths) =>
                      onChanged(segment.withBreaths(breaths)),
                ),
              ),
            Wrap(
              alignment: WrapAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  tooltip: 'Move $part up',
                  onPressed: index > 0 ? () => onMove(-1) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward_rounded),
                  tooltip: 'Move $part down',
                  onPressed: index < count - 1 ? () => onMove(1) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Remove $part',
                  onPressed: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeading extends StatelessWidget {
  const _SheetHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}
