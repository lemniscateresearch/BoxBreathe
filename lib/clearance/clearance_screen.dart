import 'package:flutter/material.dart';

import '../common/audio/session_audio.dart';
import '../common/widgets/option_picker.dart';
import '../common/widgets/page_frame.dart';
import '../common/widgets/session_layout.dart';
import '../common/widgets/setup_sheet.dart';
import '../common/widgets/step_prompt.dart';
import '../settings/settings_scope.dart';
import 'clearance_routine.dart';
import 'clearance_session.dart';
import 'clearance_step.dart';
import 'widgets/clearance_controls.dart';
import 'widgets/clearance_visual.dart';

/// The airway clearance page. It owns a [ClearanceSession] and lays out
/// the widgets that show and control it.
class ClearanceScreen extends StatefulWidget {
  const ClearanceScreen({super.key});

  @override
  State<ClearanceScreen> createState() => _ClearanceScreenState();
}

class _ClearanceScreenState extends State<ClearanceScreen>
    with SingleTickerProviderStateMixin {
  late final SessionAudio _audio;
  late final ClearanceSession _session;

  @override
  void initState() {
    super.initState();
    _audio = SessionAudio.of(context);
    _session = ClearanceSession(
      vsync: this,
      cues: _audio.cues,
      settings: SettingsScope.read(context).settings.clearance,
    );
    _audio.playMusicDuring(_session);
  }

  @override
  void dispose() {
    _session.dispose();
    _audio.dispose();
    super.dispose();
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
    final step = session.step;
    final mutedStyle = _mutedStyle(context);

    return SessionLayout(
      visual: ClearanceVisual(
        animation: session.stepProgress,
        step: step,
        isRunning: session.isRunning,
        isFinished: session.isFinished,
      ),
      prompt: StepPrompt(
        switchKey: session.isFinished ? 'finished' : session.stepIndex,
        title: session.isFinished ? 'Session complete' : step.kind.title,
        message: session.isFinished
            ? 'Well done. Rest for a while before you continue.'
            : step.kind.cue,
      ),
      details: Text(
        session.isFinished ? '' : _progressLabel(step),
        textAlign: TextAlign.center,
        style: mutedStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      showSetup: session.canChangeSettings,
      setup: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            session.isFinished
                ? 'Your airways had some care today.'
                : session.routine.description,
            textAlign: TextAlign.center,
            style: mutedStyle,
          ),
          const SizedBox(height: 12),
          SetupSummaryButton(
            label: session.routine.label,
            onPressed: () => _openSetup(context),
          ),
          const SizedBox(height: 12),
          _safetyNote(context),
        ],
      ),
      controls: ClearanceControls(session: session),
    );
  }

  void _openSetup(BuildContext context) => showSetupSheet(
    context,
    listenable: _session,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OptionPicker<ClearanceRoutine>(
          title: 'Choose a routine',
          options: ClearanceRoutine.values,
          selected: _session.routine,
          labelOf: (routine) => routine.label,
          onSelected: _session.selectRoutine,
        ),
        const SizedBox(height: 20),
        _safetyNote(context),
      ],
    ),
  );

  TextStyle _mutedStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    fontSize: 16,
  );

  Widget _safetyNote(BuildContext context) => Text(
    'Follow the advice of your physiotherapist or respiratory team. '
    'Stop and rest if you feel dizzy or short of breath.',
    textAlign: TextAlign.center,
    style: _mutedStyle(context).copyWith(fontSize: 13),
  );

  String _progressLabel(ClearanceStep step) {
    final cycle = 'Cycle ${step.cycle} of ${_session.settings.cycles}';
    return switch (step.kind) {
      ClearanceStepKind.huff =>
        '$cycle · Huff ${step.repetition} of ${step.repetitions}',
      ClearanceStepKind.deepBreathIn ||
      ClearanceStepKind.deepBreathHold ||
      ClearanceStepKind.deepBreathOut =>
        '$cycle · Deep breath ${step.repetition} of ${step.repetitions}',
      ClearanceStepKind.breathingControl => cycle,
    };
  }
}
