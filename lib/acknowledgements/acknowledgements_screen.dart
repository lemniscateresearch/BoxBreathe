import 'package:flutter/material.dart';

import '../common/audio/music_track.dart';
import '../common/widgets/page_frame.dart';
import 'dedication.dart';

/// Shows the dedication, the credits for the music and sounds, and a
/// link to the licenses of the open-source packages.
class AcknowledgementsScreen extends StatelessWidget {
  const AcknowledgementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = TextStyle(color: theme.colorScheme.onSurfaceVariant);

    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Acknowledgements',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dedicationText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const _SectionTitle('Music'),
          Text(
            'All music is released under CC0 1.0 (public domain). The '
            'artists do not require credit, but we thank them here.',
            style: muted,
          ),
          for (final mood in MusicMood.values) ...[
            const SizedBox(height: 16),
            Text(mood.label, style: theme.textTheme.titleSmall),
            for (final track in musicTracks.where((t) => t.mood == mood))
              _TrackCredit(track),
          ],

          const _SectionTitle('Sounds'),
          Text(
            'The cue tones were made for BoxBreathe with the script '
            'tool/generate_tones.dart. The spoken cues use the '
            'text-to-speech voice of your device.',
            style: muted,
          ),

          const SizedBox(height: 32),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'BoxBreathe',
              ),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Open-source licenses'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _TrackCredit extends StatelessWidget {
  const _TrackCredit(this.track);

  final MusicTrack track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text('${track.artist} · ${track.license}'),
          SelectableText(
            track.sourceUrl,
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
