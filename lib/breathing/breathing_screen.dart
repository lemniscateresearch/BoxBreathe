import 'package:flutter/material.dart';

import '../common/audio/session_audio.dart';
import '../common/widgets/option_picker.dart';
import '../common/widgets/page_frame.dart';
import '../common/widgets/step_prompt.dart';
import '../settings/settings_scope.dart';
import 'breathing_method.dart';
import 'breathing_phase.dart';
import 'breathing_session.dart';
import 'widgets/breathing_pacer.dart';
import 'widgets/session_clock.dart';
import 'widgets/session_controls.dart';

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
    child: ListenableBuilder(
      listenable: _session,
      builder: (context, _) => _buildContent(context),
    ),
  );

  Widget _buildContent(BuildContext context) {
    final session = _session;
    final canChangeSettings = session.canChangeSettings;

    return Column(
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
        const SizedBox(height: 36),
        // Center converts the column's tight stretch constraint into a
        // loose one so the pacer keeps its square size.
        Center(
          child: BreathingPacer(
            animation: session.phaseProgress,
            method: session.method,
            phaseIndex: session.phaseIndex,
            isFinished: session.isFinished,
          ),
        ),
        const SizedBox(height: 28),
        StepPrompt(
          switchKey: session.isFinished ? 'finished' : session.phase,
          title: session.isFinished ? 'Session complete' : session.phase.title,
          message: session.isFinished
              ? 'Well done. Take a moment before you continue.'
              : session.phase.cue,
        ),
        const SizedBox(height: 22),
        SessionClock(secondsRemaining: session.secondsRemaining),
        const SizedBox(height: 34),
        OptionPicker<BreathingMethod>(
          title: 'Choose a breathing shape',
          options: BreathingMethod.values,
          selected: session.method,
          labelOf: (method) => method.label,
          onSelected: canChangeSettings ? session.selectMethod : null,
        ),
        const SizedBox(height: 26),
        OptionPicker<int>(
          title: 'Choose a session length',
          options: BreathingSession.lengthOptions,
          selected: session.minutes,
          labelOf: (minutes) => '$minutes min',
          onSelected: canChangeSettings ? session.selectLength : null,
        ),
        const SizedBox(height: 28),
        SessionControls(session: session),
      ],
    );
  }
}
