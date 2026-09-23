import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() => runApp(const BoxBreatheApp());

class BoxBreatheApp extends StatelessWidget {
  const BoxBreatheApp({super.key});

  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
    builder: (lightDynamic, darkDynamic) {
      final ColorScheme lightScheme =
          lightDynamic ??
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF163C34),
            surface: const Color(0xFFF6F8F6),
          );
      final ColorScheme darkScheme =
          darkDynamic ??
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF163C34),
            brightness: Brightness.dark,
          );

      return MaterialApp(
        title: 'BoxBreathe',
        debugShowCheckedModeBanner: false,
        theme: _themeFor(lightScheme),
        darkTheme: _themeFor(darkScheme),
        themeMode: ThemeMode.system,
        home: const BreathingSessionScreen(),
      );
    },
  );

  ThemeData _themeFor(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: ThemeData(brightness: colorScheme.brightness).textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
  );
}

enum BreathingPhase { inhale, holdAfterInhale, exhale, holdAfterExhale }

extension BreathingPhaseDetails on BreathingPhase {
  String get title => switch (this) {
    BreathingPhase.inhale => 'Breathe in',
    BreathingPhase.holdAfterInhale || BreathingPhase.holdAfterExhale => 'Hold',
    BreathingPhase.exhale => 'Breathe out',
  };

  String get cue => switch (this) {
    BreathingPhase.inhale => 'Let the square grow with your breath.',
    BreathingPhase.holdAfterInhale => 'Keep a gentle, comfortable hold.',
    BreathingPhase.exhale => 'Let the square soften as you breathe out.',
    BreathingPhase.holdAfterExhale => 'Rest here before the next breath.',
  };

  Color get color => switch (this) {
    BreathingPhase.inhale => const Color(0xFF398F7B),
    BreathingPhase.holdAfterInhale => const Color(0xFF246457),
    BreathingPhase.exhale => const Color(0xFF6B8DC4),
    BreathingPhase.holdAfterExhale => const Color(0xFF5974A4),
  };
}

class BreathingSessionScreen extends StatefulWidget {
  const BreathingSessionScreen({super.key});

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  static const _phaseLength = Duration(seconds: 4);
  static const _sessionOptions = [1, 3, 5, 10];

  late final AnimationController _phaseController;
  Timer? _sessionTimer;
  int _selectedMinutes = 3;
  int _secondsRemaining = 3 * 60;
  int _phaseIndex = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  BreathingPhase get _phase => BreathingPhase.values[_phaseIndex];

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(vsync: this, duration: _phaseLength)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _isRunning) _advancePhase();
      });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _phaseController.dispose();
    super.dispose();
  }

  void _startOrResume() {
    if (_secondsRemaining == 0) {
      _secondsRemaining = _selectedMinutes * 60;
      _phaseIndex = 0;
      _phaseController.reset();
    }
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _phaseController.forward();
    _sessionTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning) return;
      if (_secondsRemaining <= 1) {
        _completeSession();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _pause() {
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    _phaseController.stop();
  }

  void _reset() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _phaseController.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _phaseIndex = 0;
      _secondsRemaining = _selectedMinutes * 60;
    });
  }

  void _completeSession() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _phaseController.stop();
    setState(() {
      _secondsRemaining = 0;
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _advancePhase() {
    setState(
      () => _phaseIndex = (_phaseIndex + 1) % BreathingPhase.values.length,
    );
    _phaseController
      ..reset()
      ..forward();
  }

  void _selectDuration(int minutes) {
    if (_isRunning || _isPaused) return;
    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining = minutes * 60;
    });
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isFinished = _secondsRemaining == 0;
    final canChooseDuration = !_isRunning && !_isPaused;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'BoxBreathe',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFinished
                        ? 'A quiet moment, just for you.'
                        : 'Four steady counts. One calmer breath at a time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _BreathingSquare(
                    animation: _phaseController,
                    phase: _phase,
                    isFinished: isFinished,
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Column(
                      key: ValueKey(isFinished ? 'finished' : _phase),
                      children: [
                        Text(
                          isFinished ? 'Session complete' : _phase.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isFinished
                              ? 'Well done. Take a moment before you continue.'
                              : _phase.cue,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Semantics(
                    liveRegion: true,
                    label: 'Session time remaining: $_formattedTime',
                    child: Text(
                      _formattedTime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Text(
                    'Choose a session length',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: _sessionOptions
                        .map(
                          (minutes) => ChoiceChip(
                            label: Text('$minutes min'),
                            selected: _selectedMinutes == minutes,
                            onSelected: canChooseDuration
                                ? (_) => _selectDuration(minutes)
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: isFinished || !_isRunning
                        ? _startOrResume
                        : _pause,
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _isRunning
                          ? 'Pause session'
                          : _isPaused
                          ? 'Resume session'
                          : isFinished
                          ? 'Start again'
                          : 'Start session',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: (_isRunning || _isPaused || isFinished)
                        ? _reset
                        : null,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingSquare extends StatelessWidget {
  const _BreathingSquare({
    required this.animation,
    required this.phase,
    required this.isFinished,
  });

  final Animation<double> animation;
  final BreathingPhase phase;
  final bool isFinished;

  @override
  Widget build(BuildContext context) => Semantics(
    label: isFinished
        ? 'Breathing session complete'
        : '${phase.title}. Follow the moving square.',
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final scale = switch (phase) {
          BreathingPhase.inhale => 0.62 + (0.38 * progress),
          BreathingPhase.holdAfterInhale => 1.0,
          BreathingPhase.exhale => 1.0 - (0.38 * progress),
          BreathingPhase.holdAfterExhale => 0.62,
        };
        return SizedBox.square(
          dimension: 230,
          child: Center(
            child: Transform.scale(
              scale: isFinished ? 0.62 : scale,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: phase.color.withValues(alpha: 0.14),
                  border: Border.all(color: phase.color, width: 7),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: phase.color.withValues(alpha: 0.16),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
