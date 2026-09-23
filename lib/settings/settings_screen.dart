import 'dart:async';

import 'package:flutter/material.dart';

import '../clearance/clearance_routine.dart';
import '../common/audio/audio_scope.dart';
import '../common/audio/audio_services.dart';
import '../common/audio/music_track.dart';
import '../common/audio/session_cue.dart';
import '../common/audio/settings_cue_player.dart';
import '../common/int_range.dart';
import '../common/widgets/number_stepper.dart';
import '../common/widgets/option_picker.dart';
import '../common/widgets/page_frame.dart';
import 'app_settings.dart';
import 'settings_scope.dart';

/// Lets the user change the sound, music, breathing pace and airway
/// clearance counts. Each change is saved at once and applies to the
/// next session.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsCuePlayer _sampleCues;
  late final MusicPlayer _preview;
  String? _previewTrackId;

  @override
  void initState() {
    super.initState();
    final audio = AudioScope.of(context);
    _sampleCues = SettingsCuePlayer(
      settings: SettingsScope.read(context),
      tones: audio.createSoundPlayer(),
      voice: audio.createVoice(),
    );
    _preview = audio.createMusicPlayer();
  }

  @override
  void dispose() {
    unawaited(_sampleCues.dispose());
    unawaited(_preview.dispose());
    super.dispose();
  }

  void _togglePreview(MusicTrack track, double volume) {
    if (_previewTrackId == track.id) {
      unawaited(_preview.fadeOutAndStop());
      setState(() => _previewTrackId = null);
    } else {
      unawaited(_preview.start(track.assetPath, volume));
      setState(() => _previewTrackId = track.id);
    }
  }

  Future<void> _confirmRestoreDefaults() async {
    final controller = SettingsScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore the default settings?'),
        content: const Text(
          'This changes all sound, music, breathing and airway clearance '
          'settings back to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) controller.restoreDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScope.of(context);
    final s = controller.settings;
    void update(AppSettings next) => controller.update(next);
    void updateClearance(ClearanceSettings next) =>
        update(s.copyWith(clearance: next));

    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settings',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const _Note('Changes apply to the next session.'),

          const _SectionTitle('Sound cues'),
          const _Note('How the app tells you that a new step starts.'),
          const SizedBox(height: 12),
          SegmentedButton<CueMode>(
            segments: [
              for (final mode in CueMode.values)
                ButtonSegment(value: mode, label: Text(mode.label)),
            ],
            selected: {s.cueMode},
            showSelectedIcon: false,
            onSelectionChanged: (modes) =>
                update(s.copyWith(cueMode: modes.single)),
          ),
          const SizedBox(height: 20),
          OptionPicker<ToneStyle>(
            title: 'Tone style',
            options: ToneStyle.values,
            selected: s.toneStyle,
            labelOf: (style) => style.label,
            onSelected: s.cueMode.playsTones
                ? (style) => update(s.copyWith(toneStyle: style))
                : null,
          ),
          const SizedBox(height: 12),
          _VolumeSlider(
            label: 'Tone volume',
            value: s.cueVolume,
            onChanged: s.cueMode.playsTones
                ? (volume) => update(s.copyWith(cueVolume: volume))
                : null,
          ),
          const _Note('The voice uses the media volume of your device.'),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton.icon(
              onPressed: s.cueMode == CueMode.off
                  ? null
                  : () => unawaited(
                      _sampleCues.play(SessionCue.breatheIn, 'Breathe in'),
                    ),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Play a sample'),
            ),
          ),

          const _SectionTitle('Music'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Play music during sessions'),
            value: s.musicEnabled,
            onChanged: (enabled) => update(s.copyWith(musicEnabled: enabled)),
          ),
          _VolumeSlider(
            label: 'Music volume',
            value: s.musicVolume,
            onChanged: s.musicEnabled
                ? (volume) => update(s.copyWith(musicVolume: volume))
                : null,
          ),
          for (final mood in MusicMood.values) ...[
            const SizedBox(height: 8),
            Text(mood.label, style: Theme.of(context).textTheme.titleSmall),
            for (final track in musicTracks.where((t) => t.mood == mood))
              _TrackTile(
                track: track,
                isSelected: track.id == s.musicTrackId,
                isPreviewing: track.id == _previewTrackId,
                enabled: s.musicEnabled,
                onSelected: () => update(s.copyWith(musicTrackId: track.id)),
                onPreview: () => _togglePreview(track, s.musicVolume),
              ),
          ],

          const _SectionTitle('Breathing'),
          NumberStepper(
            label: 'Seconds per phase',
            value: s.breathingPhaseSeconds,
            range: AppSettings.breathingPhaseSecondsRange,
            unit: ' s',
            onChanged: (seconds) =>
                update(s.copyWith(breathingPhaseSeconds: seconds)),
          ),

          const _SectionTitle('Airway clearance'),
          const _Note(
            'Ask your physiotherapist or respiratory team which values to '
            'use.',
          ),
          const SizedBox(height: 8),
          ..._clearanceSteppers(s.clearance, updateClearance),

          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: s == AppSettings.defaults
                  ? null
                  : _confirmRestoreDefaults,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Restore default settings'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _clearanceSteppers(
    ClearanceSettings c,
    ValueChanged<ClearanceSettings> update,
  ) {
    NumberStepper seconds(
      String label,
      Duration value,
      IntRange range,
      ClearanceSettings Function(Duration) apply,
    ) => NumberStepper(
      label: label,
      value: value.inSeconds,
      range: range,
      unit: ' s',
      onChanged: (seconds) => update(apply(Duration(seconds: seconds))),
    );

    return [
      NumberStepper(
        label: 'Cycles',
        value: c.cycles,
        range: ClearanceSettings.cyclesRange,
        onChanged: (value) => update(c.copyWith(cycles: value)),
      ),
      seconds(
        'Relaxed breathing',
        c.breathingControl,
        ClearanceSettings.breathingControlSecondsRange,
        (value) => c.copyWith(breathingControl: value),
      ),
      NumberStepper(
        label: 'Deep breaths',
        value: c.deepBreaths,
        range: ClearanceSettings.deepBreathsRange,
        onChanged: (value) => update(c.copyWith(deepBreaths: value)),
      ),
      seconds(
        'Deep breath in',
        c.deepBreathIn,
        ClearanceSettings.deepBreathSecondsRange,
        (value) => c.copyWith(deepBreathIn: value),
      ),
      seconds(
        'Deep breath hold',
        c.deepBreathHold,
        ClearanceSettings.deepBreathSecondsRange,
        (value) => c.copyWith(deepBreathHold: value),
      ),
      seconds(
        'Deep breath out',
        c.deepBreathOut,
        ClearanceSettings.deepBreathSecondsRange,
        (value) => c.copyWith(deepBreathOut: value),
      ),
      NumberStepper(
        label: 'Huffs per set',
        value: c.huffsPerSet,
        range: ClearanceSettings.huffsPerSetRange,
        onChanged: (value) => update(c.copyWith(huffsPerSet: value)),
      ),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 14,
    ),
  );
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;

  /// Null disables the slider.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: 120, child: Text(label)),
      Expanded(
        child: Slider(
          value: value,
          divisions: 10,
          label: '${(value * 100).round()}%',
          semanticFormatterCallback: (value) =>
              '$label ${(value * 100).round()} percent',
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.track,
    required this.isSelected,
    required this.isPreviewing,
    required this.enabled,
    required this.onSelected,
    required this.onPreview,
  });

  final MusicTrack track;
  final bool isSelected;
  final bool isPreviewing;
  final bool enabled;
  final VoidCallback onSelected;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    enabled: enabled,
    selected: isSelected,
    leading: Icon(
      isSelected
          ? Icons.radio_button_checked_rounded
          : Icons.radio_button_unchecked_rounded,
    ),
    title: Text(track.title),
    subtitle: Text(track.artist),
    onTap: onSelected,
    trailing: IconButton(
      icon: Icon(isPreviewing ? Icons.stop_rounded : Icons.play_arrow_rounded),
      tooltip: isPreviewing
          ? 'Stop the preview of ${track.title}'
          : 'Play a preview of ${track.title}',
      onPressed: enabled ? onPreview : null,
    ),
  );
}
