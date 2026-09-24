import 'package:flutter/material.dart';

import '../common/audio/session_audio.dart';
import '../common/widgets/option_picker.dart';
import '../common/widgets/page_frame.dart';
import '../common/widgets/session_layout.dart';
import '../common/widgets/setup_sheet.dart';
import '../common/widgets/step_prompt.dart';
import '../common/widgets/step_session_controls.dart';
import '../settings/settings_scope.dart';
import 'breathing_method.dart';
import 'breathing_phase.dart';
import 'breathing_session.dart';
import 'widgets/breathing_pacer.dart';
import 'widgets/session_clock.dart';

/// The guided breathing page. It owns a [BreathingSession] and lays out
/// the widgets that show and control it.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final SessionAudio _audio;
  late final BreathingSession _session;

  @override
  void initState() {
    super.initState();
    final settings = SettingsScope.read(context).settings;
    _audio = SessionAudio.of(context);
    _session = BreathingSession(
      vsync: this,
      cues: _audio.cues,
      phaseLength: Duration(seconds: settings.breathingPhaseSeconds),
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

    return SessionLayout(
      visual: BreathingPacer(
        animation: session.phaseProgress,
        method: session.method,
        phaseIndex: session.phaseIndex,
        isFinished: session.isFinished,
      ),
      prompt: StepPrompt(
        switchKey: session.isFinished ? 'finished' : session.phase,
        title: session.isFinished ? 'Session complete' : session.phase.title,
        message: session.isFinished
            ? 'Well done. Take a moment before you continue.'
            : session.phase.cue,
      ),
      details: ListenableBuilder(
        listenable: session.stepProgress,
        builder: (context, _) => SessionClock(
          secondsRemaining: session.secondsRemaining,
          breathsRemaining: session.breaths - session.step.breath + 1,
        ),
      ),
      showSetup: session.canChangeSettings,
      setup: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            session.isFinished
                ? 'A quiet moment, just for you.'
                : session.method.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SetupSummaryButton(
            label: '${session.method.label} · ${session.minutes} min',
            onPressed: () => _openSetup(context),
          ),
        ],
      ),
      controls: StepSessionControls(session: session),
    );
  }

  void _openSetup(BuildContext context) => showSetupSheet(
    context,
    listenable: _session,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OptionPicker<BreathingMethod>(
          title: 'Choose a breathing shape',
          options: BreathingMethod.values,
          selected: _session.method,
          labelOf: (method) => method.label,
          onSelected: _session.selectMethod,
        ),
        const SizedBox(height: 26),
        OptionPicker<int>(
          title: 'Choose a session length',
          options: BreathingSession.lengthOptions,
          selected: _session.minutes,
          labelOf: (minutes) => '$minutes min',
          onSelected: _session.selectLength,
        ),
      ],
    ),
  );
}
