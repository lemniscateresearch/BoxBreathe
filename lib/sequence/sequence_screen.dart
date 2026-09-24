import 'package:flutter/material.dart';

import '../common/audio/session_audio.dart';
import '../common/widgets/option_picker.dart';
import '../common/widgets/page_frame.dart';
import '../common/widgets/safety_note.dart';
import '../common/widgets/session_layout.dart';
import '../common/widgets/setup_sheet.dart';
import '../common/widgets/step_prompt.dart';
import '../settings/settings_scope.dart';
import 'exercise_sequence.dart';
import 'sequence_editor_screen.dart';
import 'sequence_library.dart';
import 'sequence_scope.dart';
import 'sequence_session.dart';
import 'sequence_timeline.dart';
import 'widgets/sequence_controls.dart';
import 'widgets/sequence_visual.dart';

/// The sequences page. The user picks one of their sequences and plays
/// it as one session. It owns a [SequenceSession] and lays out the
/// widgets that show and control it.
class SequenceScreen extends StatefulWidget {
  const SequenceScreen({super.key});

  @override
  State<SequenceScreen> createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen>
    with SingleTickerProviderStateMixin {
  late final SessionAudio _audio;
  late final SequenceLibrary _library;
  late final SequenceSession _session;

  @override
  void initState() {
    super.initState();
    final settings = SettingsScope.read(context).settings;
    _audio = SessionAudio.of(context);
    _library = SequenceScope.read(context);
    _session = SequenceSession(
      vsync: this,
      cues: _audio.cues,
      phaseLength: Duration(seconds: settings.breathingPhaseSeconds),
      clearance: settings.clearance,
    );
    _session.selectSequence(_library.sequences.firstOrNull);
    _library.addListener(_onLibraryChanged);
    _audio.playMusicDuring(_session);
  }

  @override
  void dispose() {
    _library.removeListener(_onLibraryChanged);
    _session.dispose();
    _audio.dispose();
    super.dispose();
  }

  /// Picks up edits to the selected sequence. When it was deleted, the
  /// first sequence takes its place.
  void _onLibraryChanged() {
    final current = _library.byId(_session.sequence?.id);
    final next = current ?? _library.sequences.firstOrNull;
    if (next != _session.sequence) _session.selectSequence(next);
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    scrollable: false,
    child: ListenableBuilder(
      listenable: _session,
      builder: (context, _) => _buildContent(context),
    ),
  );

  Widget _buildContent(BuildContext context) {
    final session = _session;
    final sequence = session.sequence;
    final step = session.step;
    final mutedStyle = _mutedStyle(context);

    final (title, message) = switch (step) {
      _ when session.isFinished => (
        'Sequence complete',
        'Well done. Rest for a while before you continue.',
      ),
      null when sequence == null => (
        'Your own sequence',
        'Put breathing shapes and airway clearance in the order you like.',
      ),
      null => ('No parts yet', 'Edit the sequence to add some parts.'),
      _ => (step.title, step.cue),
    };

    return SessionLayout(
      visual: SequenceVisual(session: session),
      prompt: StepPrompt(
        switchKey: session.isFinished ? 'finished' : session.stepIndex,
        title: title,
        message: message,
      ),
      details: Text(
        step == null || session.isFinished
            ? ''
            : 'Part ${step.segmentIndex + 1} of ${sequence!.segments.length}'
                  ' · ${step.progressLabel}',
        textAlign: TextAlign.center,
        style: mutedStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      showSetup: session.canChangeSettings,
      setup: sequence == null
          ? Center(
              child: FilledButton.tonalIcon(
                onPressed: () => _createAndEdit(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create a sequence'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  session.isFinished
                      ? 'A quiet moment, just for you.'
                      : sequence.segments.isEmpty
                      ? sequence.summary
                      : lengthLabel(session.steps),
                  textAlign: TextAlign.center,
                  style: mutedStyle,
                ),
                const SizedBox(height: 12),
                SetupSummaryButton(
                  label: _summaryLabel(sequence),
                  onPressed: () => _openSetup(context),
                ),
                if (sequence.hasClearance) ...[
                  const SizedBox(height: 12),
                  const SafetyNote(),
                ],
              ],
            ),
      controls: SequenceControls(session: session),
    );
  }

  String _summaryLabel(ExerciseSequence sequence) {
    final count = sequence.segments.length;
    return '${sequence.displayName} · $count ${count == 1 ? 'part' : 'parts'}';
  }

  void _openSetup(BuildContext context) => showSetupSheet(
    context,
    listenable: Listenable.merge([_session, _library]),
    builder: (context) {
      final selected = _session.sequence;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selected != null) ...[
            OptionPicker<ExerciseSequence>(
              title: 'Choose a sequence',
              options: _library.sequences,
              selected: selected,
              labelOf: (sequence) => sequence.displayName,
              onSelected: _session.selectSequence,
            ),
            const SizedBox(height: 12),
            Text(
              selected.summary,
              textAlign: TextAlign.center,
              style: _mutedStyle(context),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => _edit(context, selected),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit this sequence'),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () => _createAndEdit(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New sequence'),
          ),
        ],
      );
    },
  );

  /// Makes a new sequence and opens it in the editor. If the user leaves
  /// the editor without adding a part, the empty sequence is removed.
  Future<void> _createAndEdit(BuildContext context) async {
    final sequence = _library.create();
    _session.selectSequence(sequence);
    await _edit(context, sequence);
    if (_library.byId(sequence.id)?.segments.isEmpty ?? false) {
      _library.remove(sequence.id);
    }
  }

  Future<void> _edit(BuildContext context, ExerciseSequence sequence) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => SequenceEditorScreen(sequenceId: sequence.id),
        ),
      );

  TextStyle _mutedStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    fontSize: 16,
  );
}
