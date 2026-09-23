import '../clearance/clearance_routine.dart';
import '../common/audio/music_track.dart';
import '../common/int_range.dart';

/// How the app tells the user that a new step starts.
enum CueMode { tones, voice, tonesAndVoice, off }

extension CueModeDetails on CueMode {
  String get label => switch (this) {
    CueMode.tones => 'Tones',
    CueMode.voice => 'Voice',
    CueMode.tonesAndVoice => 'Both',
    CueMode.off => 'Off',
  };

  bool get playsTones => this == CueMode.tones || this == CueMode.tonesAndVoice;
  bool get speaks => this == CueMode.voice || this == CueMode.tonesAndVoice;
}

/// A set of cue tones in `assets/sounds/<folder>/`. The script
/// `tool/generate_tones.dart` makes them.
enum ToneStyle { chimes, singingBowl, softBeeps }

extension ToneStyleDetails on ToneStyle {
  String get label => switch (this) {
    ToneStyle.chimes => 'Chimes',
    ToneStyle.singingBowl => 'Singing bowl',
    ToneStyle.softBeeps => 'Soft beeps',
  };

  String get folder => switch (this) {
    ToneStyle.chimes => 'chimes',
    ToneStyle.singingBowl => 'singing_bowl',
    ToneStyle.softBeeps => 'soft_beeps',
  };
}

/// All the settings that the user can change. The settings page edits
/// them, and each session reads them when it starts.
class AppSettings {
  const AppSettings({
    required this.cueMode,
    required this.toneStyle,
    required this.cueVolume,
    required this.musicEnabled,
    required this.musicTrackId,
    required this.musicVolume,
    required this.breathingPhaseSeconds,
    required this.clearance,
  });

  static const defaults = AppSettings(
    cueMode: CueMode.tonesAndVoice,
    toneStyle: ToneStyle.chimes,
    cueVolume: 0.8,
    musicEnabled: true,
    musicTrackId: 'calm_piano_vaporware',
    musicVolume: 0.4,
    breathingPhaseSeconds: 4,
    clearance: ClearanceSettings.defaults,
  );

  static const breathingPhaseSecondsRange = IntRange(3, 6);

  final CueMode cueMode;
  final ToneStyle toneStyle;

  /// From 0 (silent) to 1 (full volume).
  final double cueVolume;

  final bool musicEnabled;

  /// The [MusicTrack.id] of the selected track.
  final String musicTrackId;

  /// From 0 (silent) to 1 (full volume).
  final double musicVolume;

  final int breathingPhaseSeconds;
  final ClearanceSettings clearance;

  MusicTrack get musicTrack =>
      MusicTrack.byId(musicTrackId) ?? MusicTrack.byId(defaults.musicTrackId)!;

  AppSettings copyWith({
    CueMode? cueMode,
    ToneStyle? toneStyle,
    double? cueVolume,
    bool? musicEnabled,
    String? musicTrackId,
    double? musicVolume,
    int? breathingPhaseSeconds,
    ClearanceSettings? clearance,
  }) => AppSettings(
    cueMode: cueMode ?? this.cueMode,
    toneStyle: toneStyle ?? this.toneStyle,
    cueVolume: cueVolume ?? this.cueVolume,
    musicEnabled: musicEnabled ?? this.musicEnabled,
    musicTrackId: musicTrackId ?? this.musicTrackId,
    musicVolume: musicVolume ?? this.musicVolume,
    breathingPhaseSeconds: breathingPhaseSeconds ?? this.breathingPhaseSeconds,
    clearance: clearance ?? this.clearance,
  );

  /// Moves every value into its permitted range, and replaces an unknown
  /// music track with the default track.
  AppSettings clamped() => copyWith(
    cueVolume: cueVolume.clamp(0.0, 1.0),
    musicTrackId: musicTrack.id,
    musicVolume: musicVolume.clamp(0.0, 1.0),
    breathingPhaseSeconds: breathingPhaseSecondsRange.clamp(
      breathingPhaseSeconds,
    ),
    clearance: clearance.clamped(),
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.cueMode == cueMode &&
      other.toneStyle == toneStyle &&
      other.cueVolume == cueVolume &&
      other.musicEnabled == musicEnabled &&
      other.musicTrackId == musicTrackId &&
      other.musicVolume == musicVolume &&
      other.breathingPhaseSeconds == breathingPhaseSeconds &&
      other.clearance == clearance;

  @override
  int get hashCode => Object.hash(
    cueMode,
    toneStyle,
    cueVolume,
    musicEnabled,
    musicTrackId,
    musicVolume,
    breathingPhaseSeconds,
    clearance,
  );
}
