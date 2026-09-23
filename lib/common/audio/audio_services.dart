import 'cue_player.dart';

/// Plays short sounds, such as cue tones. A new sound stops the sound
/// that plays.
abstract interface class SoundPlayer {
  /// Plays the asset at [assetPath] (relative to `assets/`) at [volume],
  /// from 0 to 1.
  Future<void> play(String assetPath, double volume);
  Future<void> stop();
  Future<void> dispose();
}

/// Plays one music track in a loop.
abstract interface class MusicPlayer {
  /// Starts the asset at [assetPath] (relative to `assets/`) from the
  /// beginning, at [volume], from 0 to 1.
  Future<void> start(String assetPath, double volume);
  Future<void> pause();
  Future<void> resume();

  /// Lowers the volume to 0 gradually, then stops.
  Future<void> fadeOutAndStop();
  Future<void> dispose();
}

/// Makes the audio players. The app uses real players on a device, and
/// tests use silent players.
abstract interface class AudioServices {
  SoundPlayer createSoundPlayer();
  MusicPlayer createMusicPlayer();

  /// A player that says the words of each cue.
  CuePlayer createVoice();
}

class SilentAudioServices implements AudioServices {
  const SilentAudioServices();

  @override
  SoundPlayer createSoundPlayer() => const _SilentSoundPlayer();

  @override
  MusicPlayer createMusicPlayer() => const _SilentMusicPlayer();

  @override
  CuePlayer createVoice() => const SilentCuePlayer();
}

class _SilentSoundPlayer implements SoundPlayer {
  const _SilentSoundPlayer();

  @override
  Future<void> play(String assetPath, double volume) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class _SilentMusicPlayer implements MusicPlayer {
  const _SilentMusicPlayer();

  @override
  Future<void> start(String assetPath, double volume) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> fadeOutAndStop() async {}

  @override
  Future<void> dispose() async {}
}
