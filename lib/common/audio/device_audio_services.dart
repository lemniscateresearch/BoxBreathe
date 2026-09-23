import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'audio_services.dart';
import 'cue_player.dart';
import 'tts_cue_speaker.dart';

/// Makes players that use the audio of the device.
class DeviceAudioServices implements AudioServices {
  DeviceAudioServices._();

  /// Lets the music, the tones and the voice play at the same time, and
  /// also with audio from other apps.
  static Future<DeviceAudioServices> init() async {
    await _guard(
      () => AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers)
            .build(),
      ),
    );
    return DeviceAudioServices._();
  }

  @override
  SoundPlayer createSoundPlayer() => _DeviceSoundPlayer();

  @override
  MusicPlayer createMusicPlayer() => _DeviceMusicPlayer();

  @override
  CuePlayer createVoice() => TtsCueSpeaker();
}

/// Sound only helps the user, so an audio failure is logged and does not
/// stop the app.
Future<void> _guard(Future<void> Function() action) async {
  try {
    await action();
  } catch (error) {
    debugPrint('Audio failed: $error');
  }
}

class _DeviceSoundPlayer implements SoundPlayer {
  final _player = AudioPlayer();

  @override
  Future<void> play(String assetPath, double volume) => _guard(() async {
    await _player.stop();
    await _player.play(
      AssetSource(assetPath),
      volume: volume,
      mode: PlayerMode.lowLatency,
    );
  });

  @override
  Future<void> stop() => _guard(_player.stop);

  @override
  Future<void> dispose() => _guard(_player.dispose);
}

class _DeviceMusicPlayer implements MusicPlayer {
  static const _fadeLength = Duration(milliseconds: 1500);
  static const _fadeSteps = 30;

  final _player = AudioPlayer();
  double _volume = 1;
  Timer? _fade;

  @override
  Future<void> start(String assetPath, double volume) => _guard(() async {
    _cancelFade();
    _volume = volume;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(assetPath), volume: volume);
  });

  @override
  Future<void> pause() => _guard(() async {
    _cancelFade();
    await _player.pause();
  });

  @override
  Future<void> resume() => _guard(() async {
    _cancelFade();
    await _player.setVolume(_volume);
    await _player.resume();
  });

  @override
  Future<void> fadeOutAndStop() {
    _cancelFade();
    final done = Completer<void>();
    var step = 0;
    _fade = Timer.periodic(_fadeLength ~/ _fadeSteps, (timer) {
      step++;
      final volume = _volume * (1 - step / _fadeSteps);
      unawaited(_guard(() => _player.setVolume(volume)));
      if (step == _fadeSteps) {
        timer.cancel();
        _fade = null;
        unawaited(_guard(_player.stop).whenComplete(done.complete));
      }
    });
    return done.future;
  }

  void _cancelFade() {
    _fade?.cancel();
    _fade = null;
  }

  @override
  Future<void> dispose() async {
    _cancelFade();
    await _guard(_player.dispose);
  }
}
