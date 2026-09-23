import 'package:flutter/material.dart';

import '../common/widgets/option_picker.dart';
import 'breathing_method.dart';
import 'breathing_session.dart';
import 'widgets/breathing_pacer.dart';
import 'widgets/phase_prompt.dart';
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
  late final _session = BreathingSession(vsync: this);

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
        PhasePrompt(phase: session.phase, isFinished: session.isFinished),
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
