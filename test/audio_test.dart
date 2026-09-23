import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:box_breathe/common/audio/music_track.dart';
import 'package:box_breathe/common/audio/session_cue.dart';
import 'package:box_breathe/common/audio/session_music.dart';
import 'package:box_breathe/common/audio/settings_cue_player.dart';
import 'package:box_breathe/common/session_status.dart';
import 'package:box_breathe/settings/app_settings.dart';
import 'package:box_breathe/settings/settings_controller.dart';
import 'package:box_breathe/settings/settings_store.dart';

import 'fakes.dart';

void main() {
  group('SettingsCuePlayer', () {
    late FakeSoundPlayer tones;
    late FakeCuePlayer voice;
    late SettingsController settings;
    late SettingsCuePlayer player;

    setUp(() {
      tones = FakeSoundPlayer();
      voice = FakeCuePlayer();
      settings = SettingsController(MemorySettingsStore());
      player = SettingsCuePlayer(
        settings: settings,
        tones: tones,
        voice: voice,
      );
    });

    Future<void> playWith(CueMode mode) async {
      settings.update(
        settings.settings.copyWith(
          cueMode: mode,
          toneStyle: ToneStyle.softBeeps,
          cueVolume: 0.5,
        ),
      );
      await player.play(SessionCue.hold, 'Hold');
    }

    test('plays only the tone for tones', () async {
      await playWith(CueMode.tones);
      expect(tones.calls, ['play sounds/soft_beeps/hold.wav 0.5']);
      expect(voice.words, isEmpty);
    });

    test('says only the words for voice', () async {
      await playWith(CueMode.voice);
      expect(tones.calls, isEmpty);
      expect(voice.words, ['Hold']);
    });

    test('plays the tone and says the words for both', () async {
      await playWith(CueMode.tonesAndVoice);
      expect(tones.calls, hasLength(1));
      expect(voice.words, ['Hold']);
    });

    test('plays nothing when cues are off', () async {
      await playWith(CueMode.off);
      expect(tones.calls, isEmpty);
      expect(voice.words, isEmpty);
    });
  });

  group('SessionMusic', () {
    final track = musicTracks.first;

    test('follows the session status', () {
      final session = FakeSession();
      final player = FakeMusicPlayer();
      SessionMusic(session: session, player: player, track: track, volume: 0.4);

      session.status = SessionStatus.running;
      session.status = SessionStatus.paused;
      session.status = SessionStatus.running;
      session.status = SessionStatus.finished;
      session.status = SessionStatus.running;
      session.status = SessionStatus.idle;

      expect(player.calls, [
        'start ${track.assetPath} 0.4',
        'pause',
        'resume',
        'fadeOut',
        'start ${track.assetPath} 0.4',
        'fadeOut',
      ]);
    });

    test('does nothing when the music is off', () {
      final session = FakeSession();
      final player = FakeMusicPlayer();
      SessionMusic(session: session, player: player, track: null, volume: 1);

      session.status = SessionStatus.running;
      session.status = SessionStatus.finished;

      expect(player.calls, isEmpty);
    });
  });

  group('assets', () {
    test('every tone style has a file for every cue', () {
      for (final style in ToneStyle.values) {
        for (final cue in SessionCue.values) {
          final path = 'assets/${SettingsCuePlayer.toneAsset(style, cue)}';
          expect(File(path).existsSync(), isTrue, reason: path);
        }
      }
    });

    test('every music track has a file', () {
      for (final track in musicTracks) {
        final path = 'assets/${track.assetPath}';
        expect(File(path).existsSync(), isTrue, reason: path);
      }
      expect(musicTracks.map((track) => track.id).toSet(), hasLength(11));
    });
  });
}
