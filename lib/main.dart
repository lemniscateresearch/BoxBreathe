import 'dart:async';
import 'dart:math' as math;

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
        home: const AppShell(),
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
    BreathingPhase.inhale => 'Let the shape guide your breath in.',
    BreathingPhase.holdAfterInhale => 'Keep a gentle, comfortable hold.',
    BreathingPhase.exhale => 'Let the shape guide your breath out.',
    BreathingPhase.holdAfterExhale => 'Rest here before the next breath.',
  };

  Color get color => switch (this) {
    BreathingPhase.inhale => const Color(0xFF398F7B),
    BreathingPhase.holdAfterInhale => const Color(0xFF246457),
    BreathingPhase.exhale => const Color(0xFF6B8DC4),
    BreathingPhase.holdAfterExhale => const Color(0xFF5974A4),
  };
}

/// The pages that the sidebar offers. New modes (for example the
/// forced-expiration technique) become a new page here.
enum AppPage { breathing }

extension AppPageDetails on AppPage {
  String get label => switch (this) { AppPage.breathing => 'Breathing' };

  IconData get icon => switch (this) {
    AppPage.breathing => Icons.self_improvement_rounded,
  };
}

enum BreathingMethod { box, figureEight, triangle }

extension BreathingMethodDetails on BreathingMethod {
  String get label => switch (this) {
    BreathingMethod.box => 'Box',
    BreathingMethod.figureEight => 'Figure eight',
    BreathingMethod.triangle => 'Triangle',
  };

  String get description => switch (this) {
    BreathingMethod.box => 'Trace the square. In, hold, out, hold.',
    BreathingMethod.figureEight =>
      'Trace the eight. In on one loop, out on the other.',
    BreathingMethod.triangle => 'Trace the triangle. In, hold, out.',
  };

  List<BreathingPhase> get phases => switch (this) {
    BreathingMethod.box => const [
      BreathingPhase.inhale,
      BreathingPhase.holdAfterInhale,
      BreathingPhase.exhale,
      BreathingPhase.holdAfterExhale,
    ],
    BreathingMethod.figureEight => const [
      BreathingPhase.inhale,
      BreathingPhase.exhale,
    ],
    BreathingMethod.triangle => const [
      BreathingPhase.inhale,
      BreathingPhase.holdAfterInhale,
      BreathingPhase.exhale,
    ],
  };

  /// Builds the outline that the breathing dot travels along.
  ///
  /// The path starts at the beginning of the first phase and has one
  /// equally-long segment for each phase in [phases].
  Path path(Size size, double inset) => switch (this) {
    BreathingMethod.box => _boxPath(size, inset),
    BreathingMethod.figureEight => _figureEightPath(size, inset),
    BreathingMethod.triangle => _trianglePath(size, inset),
  };
}

Path _boxPath(Size size, double inset) {
  final left = inset;
  final top = inset;
  final right = size.width - inset;
  final bottom = size.height - inset;
  return Path()
    ..moveTo(left, bottom)
    ..lineTo(left, top)
    ..lineTo(right, top)
    ..lineTo(right, bottom)
    ..close();
}

Path _trianglePath(Size size, double inset) {
  // Equilateral triangle so that all three sides have the same length.
  final side = size.width - 2 * inset;
  final height = side * math.sqrt(3) / 2;
  final centerX = size.width / 2;
  final top = inset + (size.height - height) / 2;
  final bottom = top + height;
  return Path()
    ..moveTo(centerX - side / 2, bottom)
    ..lineTo(centerX, top)
    ..lineTo(centerX + side / 2, bottom)
    ..close();
}

Path _figureEightPath(Size size, double inset) {
  // Gerono lemniscate: x = a * cos(t), y = b * sin(2t) / 2.
  // The path starts at the center crossing. The first half of the path
  // traces the right loop (breathe in), the second half traces the left
  // loop (breathe out).
  final centerX = size.width / 2;
  final centerY = size.height / 2;
  final amplitudeX = size.width / 2 - inset;
  final amplitudeY = size.height / 2 - inset;
  const samples = 96;
  final path = Path();
  for (var i = 0; i <= samples; i++) {
    final t = -math.pi / 2 + (2 * math.pi * i) / samples;
    final x = centerX + amplitudeX * math.cos(t);
    final y = centerY - amplitudeY * math.sin(2 * t);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  return path;
}

/// Hosts the pages that the sidebar offers, with the breathing screen
/// as the default page. The drawer stays above the page body and keeps
/// its state when the user switches pages.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppPage _page = AppPage.breathing;

  static const _pages = AppPage.values;

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: NavigationDrawer(
      selectedIndex: _pages.indexOf(_page),
      onDestinationSelected: (index) {
        setState(() => _page = _pages[index]);
        Navigator.of(context).pop();
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Text(
            'BoxBreathe',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final page in _pages)
          NavigationDrawerDestination(
            icon: Icon(page.icon),
            label: Text(page.label),
          ),
      ],
    ),
    body: switch (_page) {
      AppPage.breathing => const BreathingSessionScreen(),
    },
  );
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
  BreathingMethod _selectedMethod = BreathingMethod.box;

  List<BreathingPhase> get _phases => _selectedMethod.phases;

  BreathingPhase get _phase => _phases[_phaseIndex];

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
      () => _phaseIndex = (_phaseIndex + 1) % _phases.length,
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

  void _selectMethod(BreathingMethod method) {
    if (_isRunning || _isPaused) return;
    _phaseController.reset();
    setState(() {
      _selectedMethod = method;
      _phaseIndex = 0;
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
    final canAdjustSettings = !_isRunning && !_isPaused;

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isFinished
                          ? 'A quiet moment, just for you.'
                          : _selectedMethod.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 36),
                  // Center converts the column's tight stretch constraint
                  // into a loose one so the pacer keeps its square size.
                  Center(
                    child: _BreathingPacer(
                      animation: _phaseController,
                      method: _selectedMethod,
                      phaseIndex: _phaseIndex,
                      isFinished: isFinished,
                    ),
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
                    'Choose a breathing shape',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: BreathingMethod.values
                        .map(
                          (method) => ChoiceChip(
                            label: Text(method.label),
                            selected: _selectedMethod == method,
                            onSelected: canAdjustSettings
                                ? (_) => _selectMethod(method)
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 26),
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
                            onSelected: canAdjustSettings
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
  }
}

/// Shows the breathing shape with a dot that travels along its outline.
/// One phase of the breathing method equals one side or loop of the shape.
class _BreathingPacer extends StatelessWidget {
  const _BreathingPacer({
    required this.animation,
    required this.method,
    required this.phaseIndex,
    required this.isFinished,
  });

  final Animation<double> animation;
  final BreathingMethod method;
  final int phaseIndex;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    final phase = method.phases[phaseIndex];
    return Semantics(
      label: isFinished
          ? 'Breathing session complete'
          : '${phase.title}. Follow the dot along the shape.',
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => SizedBox.square(
          dimension: 260,
          child: CustomPaint(
            painter: _BreathingPacerPainter(
              method: method,
              phaseIndex: phaseIndex,
              phaseProgress: animation.value,
              isFinished: isFinished,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingPacerPainter extends CustomPainter {
  _BreathingPacerPainter({
    required this.method,
    required this.phaseIndex,
    required this.phaseProgress,
    required this.isFinished,
  });

  static const _strokeWidth = 7.0;
  static const _inset = 24.0;

  final BreathingMethod method;
  final int phaseIndex;
  final double phaseProgress;
  final bool isFinished;

  @override
  void paint(Canvas canvas, Size size) {
    final path = method.path(size, _inset);
    final metric = path.computeMetrics().first;
    final segmentLength = metric.length / method.phases.length;
    final activeColor = method.phases[phaseIndex].color;

    // Draw every side or loop in the color of its phase.
    for (var i = 0; i < method.phases.length; i++) {
      final isActive = !isFinished && i == phaseIndex;
      final segment = metric.extractPath(
        segmentLength * i,
        segmentLength * (i + 1),
      );
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = method.phases[i].color.withValues(
            alpha: isActive ? 0.45 : 0.22,
          ),
      );
    }

    if (isFinished) return;

    // Draw the part of the current segment that the user has already traced.
    final start = segmentLength * phaseIndex;
    canvas.drawPath(
      metric.extractPath(start, start + segmentLength * phaseProgress),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = activeColor,
    );

    // Draw the dot that the user follows.
    final tangent = metric.getTangentForOffset(
      start + segmentLength * phaseProgress,
    );
    if (tangent != null) {
      canvas.drawCircle(
        tangent.position,
        18,
        Paint()..color = activeColor.withValues(alpha: 0.18),
      );
      canvas.drawCircle(tangent.position, 9, Paint()..color = activeColor);
    }
  }

  @override
  bool shouldRepaint(covariant _BreathingPacerPainter oldDelegate) =>
      oldDelegate.method != method ||
      oldDelegate.phaseIndex != phaseIndex ||
      oldDelegate.phaseProgress != phaseProgress ||
      oldDelegate.isFinished != isFinished;
}
