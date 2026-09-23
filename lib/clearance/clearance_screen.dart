import 'package:flutter/material.dart';

import '../common/audio/tts_cue_speaker.dart';
import '../common/widgets/option_picker.dart';
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
  late final _session = ClearanceSession(
    vsync: this,
    cues: TtsCueSpeaker(),
    settings: SettingsScope.read(context).settings.clearance,
  );

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
              child: ListenableBuilder(
                listenable: _session,
                builder: (context, _) => _buildContent(context),
              ),
            ),
          ),
        ),
        // Menu button that opens the sidebar. It sits above the content
        // in the top-left corner and stays clear of the centered column.
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Open navigation',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    ),
  );

  Widget _buildContent(BuildContext context) {
    final session = _session;
    final step = session.step;
    final mutedStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          session.isFinished
              ? 'Your airways had some care today.'
              : session.routine.description,
          textAlign: TextAlign.center,
          style: mutedStyle,
        ),
        const SizedBox(height: 36),
        // Center converts the column's tight stretch constraint into a
        // loose one so the visual keeps its square size.
        Center(
          child: ClearanceVisual(
            animation: session.stepProgress,
            step: step,
            isRunning: session.isRunning,
            isFinished: session.isFinished,
          ),
        ),
        const SizedBox(height: 28),
        StepPrompt(
          switchKey: session.isFinished ? 'finished' : session.stepIndex,
          title: session.isFinished ? 'Session complete' : step.kind.title,
          message: session.isFinished
              ? 'Well done. Rest for a while before you continue.'
              : step.kind.cue,
        ),
        const SizedBox(height: 16),
        Text(
          session.isFinished ? '' : _progressLabel(step),
          textAlign: TextAlign.center,
          style: mutedStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 30),
        OptionPicker<ClearanceRoutine>(
          title: 'Choose a routine',
          options: ClearanceRoutine.values,
          selected: session.routine,
          labelOf: (routine) => routine.label,
          onSelected: session.canChangeSettings ? session.selectRoutine : null,
        ),
        const SizedBox(height: 28),
        ClearanceControls(session: session),
        const SizedBox(height: 20),
        Text(
          'Follow the advice of your physiotherapist or respiratory team. '
          'Stop and rest if you feel dizzy or short of breath.',
          textAlign: TextAlign.center,
          style: mutedStyle.copyWith(fontSize: 13),
        ),
      ],
    );
  }

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
