enum MusicMood { calm, upbeat }

extension MusicMoodDetails on MusicMood {
  String get label => switch (this) {
    MusicMood.calm => 'Calm',
    MusicMood.upbeat => 'Upbeat',
  };
}

/// A music track in `assets/music/`. CREDITS.md gives the same details.
class MusicTrack {
  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.mood,
    required this.sourceUrl,
  });

  /// The file name without the extension. Settings store this value.
  final String id;
  final String title;
  final String artist;
  final MusicMood mood;
  final String sourceUrl;

  String get license => 'CC0 1.0';

  /// The path for an audioplayers `AssetSource`, which adds `assets/`.
  String get assetPath => 'music/$id.mp3';

  static MusicTrack? byId(String id) {
    for (final track in musicTracks) {
      if (track.id == id) return track;
    }
    return null;
  }
}

const musicTracks = [
  MusicTrack(
    id: 'calm_piano_vaporware',
    title: 'Calm Piano 1 (Vaporware)',
    artist: 'cynicmusic',
    mood: MusicMood.calm,
    sourceUrl: 'https://opengameart.org/content/calm-piano-1-vaporware',
  ),
  MusicTrack(
    id: 'meadow_thoughts',
    title: 'Meadow Thoughts',
    artist: 'Écrivain',
    mood: MusicMood.calm,
    sourceUrl: 'https://opengameart.org/content/meadow-thoughts',
  ),
  MusicTrack(
    id: 'contemplation',
    title: 'Contemplation',
    artist: 'Joth',
    mood: MusicMood.calm,
    sourceUrl: 'https://opengameart.org/content/contemplation-0',
  ),
  MusicTrack(
    id: 'heavenly_loop',
    title: 'Heavenly Loop',
    artist: 'isaiah658',
    mood: MusicMood.calm,
    sourceUrl: 'https://opengameart.org/content/heavenly-loop',
  ),
  MusicTrack(
    id: 'another_august',
    title: 'Another August',
    artist: 'cynicmusic',
    mood: MusicMood.calm,
    sourceUrl: 'https://opengameart.org/content/another-august',
  ),
  MusicTrack(
    id: 'calm_ambient_lifewave',
    title: 'Calm Ambient 3 (Lifewave 2k)',
    artist: 'cynicmusic',
    mood: MusicMood.calm,
    sourceUrl: 'https://opengameart.org/content/calm-ambient-3-lifewave-2k',
  ),
  MusicTrack(
    id: 'summer_sunday',
    title: 'Summer Sunday',
    artist: 'celestialghost8',
    mood: MusicMood.upbeat,
    sourceUrl: 'https://opengameart.org/content/summer-sunday',
  ),
  MusicTrack(
    id: 'happy_adventure',
    title: 'Happy Adventure (Loop)',
    artist: 'TinyWorlds',
    mood: MusicMood.upbeat,
    sourceUrl: 'https://opengameart.org/content/happy-adventure-loop',
  ),
  MusicTrack(
    id: 'minstrel_dance',
    title: 'Medieval: Minstrel Dance',
    artist: 'RandomMind',
    mood: MusicMood.upbeat,
    sourceUrl: 'https://opengameart.org/content/medieval-minstrel-dance',
  ),
  MusicTrack(
    id: 'feel_good_island',
    title: 'Feel Good Island',
    artist: 'Brandon75689',
    mood: MusicMood.upbeat,
    sourceUrl: 'https://opengameart.org/content/feel-good-island',
  ),
  MusicTrack(
    id: 'bossa_nova',
    title: 'Bossa Nova',
    artist: 'Joth',
    mood: MusicMood.upbeat,
    sourceUrl: 'https://opengameart.org/content/bossa-nova',
  ),
];
