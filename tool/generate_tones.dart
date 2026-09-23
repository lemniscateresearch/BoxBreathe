// Generates the cue tones of the app as 16-bit mono WAV files.
//
// Usage:
//   dart run tool/generate_tones.dart
//     Writes the cues of every style to assets/sounds/<style>/. The app
//     uses these files. The user selects the style in the settings.
//   dart run tool/generate_tones.dart --samples
//     Writes every style to build/tone_samples/, for an audition. Each
//     style also gets one preview file with all of its cues in order.
//
// The script has no dependencies, so that anyone can change a style and
// make the tones again.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// The highest partial of every style is below 5 kHz, so 22.05 kHz keeps
/// the full sound and makes the files half the size.
const sampleRate = 22050;

/// The peak level of every file, a little below full scale.
const peakLevel = 0.6;

/// The cues that the app plays. The names are also the file names.
enum Cue { breatheIn, hold, breatheOut, huff, rest, finished }

/// One note of a cue: a pitch in semitones above the base pitch of the
/// style, and a start time in seconds.
typedef Note = ({int semitones, double start});

/// The notes of each cue. A style can move them to a different base pitch.
const Map<Cue, List<Note>> cueNotes = {
  // A rising pair of notes.
  Cue.breatheIn: [(semitones: 0, start: 0), (semitones: 7, start: 0.2)],
  // One note in the middle.
  Cue.hold: [(semitones: 4, start: 0)],
  // A falling pair of notes.
  Cue.breatheOut: [(semitones: 7, start: 0), (semitones: 0, start: 0.2)],
  // One low note, clearly different from the other cues.
  Cue.huff: [(semitones: -5, start: 0)],
  // One soft note for relaxed breathing.
  Cue.rest: [(semitones: -3, start: 0)],
  // A short rising chord at the end of a session.
  Cue.finished: [
    (semitones: 0, start: 0),
    (semitones: 4, start: 0.15),
    (semitones: 7, start: 0.3),
    (semitones: 12, start: 0.45),
  ],
};

/// The sound of one style. Each note is a sum of partials. Each partial
/// is a sine wave at a multiple of the note pitch.
class ToneStyle {
  const ToneStyle({
    required this.basePitch,
    required this.partials,
    required this.attack,
    required this.hold,
    required this.decay,
  });

  /// The pitch in Hz of semitone 0.
  final double basePitch;

  /// For each partial: the pitch multiple, the relative level, and how
  /// fast it decays compared to the note (1 = same speed, 2 = twice as
  /// fast).
  final List<({double ratio, double level, double decayRate})> partials;

  /// Seconds to reach full level.
  final double attack;

  /// Seconds at full level before the decay starts.
  final double hold;

  /// The time constant of the exponential decay, in seconds.
  final double decay;
}

const styles = {
  // Short, bright bell notes that fade gently.
  'chimes': ToneStyle(
    basePitch: 523.25, // C5
    partials: [
      (ratio: 1, level: 1, decayRate: 1),
      (ratio: 2, level: 0.35, decayRate: 1.6),
      (ratio: 3, level: 0.15, decayRate: 2.2),
      (ratio: 4.2, level: 0.06, decayRate: 3),
    ],
    attack: 0.005,
    hold: 0,
    decay: 0.35,
  ),
  // Deep notes that ring for a long time. The two close partials beat
  // slowly, like a singing bowl.
  'singing_bowl': ToneStyle(
    basePitch: 261.63, // C4
    partials: [
      (ratio: 1, level: 1, decayRate: 1),
      (ratio: 1.004, level: 0.6, decayRate: 1),
      (ratio: 2.71, level: 0.4, decayRate: 1.5),
      (ratio: 5.1, level: 0.12, decayRate: 2.5),
    ],
    attack: 0.03,
    hold: 0,
    decay: 1.1,
  ),
  // Plain, soft beeps with a short fade in and out.
  'soft_beeps': ToneStyle(
    basePitch: 659.25, // E5
    partials: [
      (ratio: 1, level: 1, decayRate: 1),
      (ratio: 2, level: 0.08, decayRate: 1),
    ],
    attack: 0.02,
    hold: 0.18,
    decay: 0.05,
  ),
};

Float64List render(ToneStyle style, List<Note> notes) {
  // Stop each note when its level is below -60 dB.
  final noteLength = style.attack + style.hold + style.decay * math.log(1000);
  final end = notes.map((note) => note.start).reduce(math.max) + noteLength;
  final samples = Float64List((end * sampleRate).ceil());

  for (final note in notes) {
    final pitch = style.basePitch * math.pow(2, note.semitones / 12);
    final offset = (note.start * sampleRate).round();
    for (var i = 0; offset + i < samples.length; i++) {
      final t = i / sampleRate;
      if (t > noteLength) break;
      var value = 0.0;
      for (final partial in style.partials) {
        final level = partial.level * _envelope(style, t, partial.decayRate);
        value += level * math.sin(2 * math.pi * pitch * partial.ratio * t);
      }
      samples[offset + i] += value;
    }
  }

  final peak = samples.map((s) => s.abs()).reduce(math.max);
  for (var i = 0; i < samples.length; i++) {
    samples[i] *= peakLevel / peak;
  }
  return samples;
}

double _envelope(ToneStyle style, double t, double decayRate) {
  if (t < style.attack) return t / style.attack;
  final afterHold = t - style.attack - style.hold;
  if (afterHold < 0) return 1;
  return math.exp(-afterHold * decayRate / style.decay);
}

Uint8List wav(Float64List samples) {
  final data = ByteData(44 + samples.length * 2);
  void ascii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little); // Size of the format chunk.
  data.setUint16(20, 1, Endian.little); // PCM.
  data.setUint16(22, 1, Endian.little); // Mono.
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little); // Bytes per second.
  data.setUint16(32, 2, Endian.little); // Bytes per sample.
  data.setUint16(34, 16, Endian.little); // Bits per sample.
  ascii(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final value = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    data.setInt16(44 + i * 2, value, Endian.little);
  }
  return data.buffer.asUint8List();
}

/// The file name of a cue, for example `breathe_in.wav`.
String fileName(Cue cue) =>
    '${cue.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}')}.wav';

void writeStyle(String name, Directory directory) {
  directory.createSync(recursive: true);
  final style = styles[name]!;
  for (final cue in Cue.values) {
    File('${directory.path}/${fileName(cue)}')
        .writeAsBytesSync(wav(render(style, cueNotes[cue]!)));
  }
}

/// Writes every cue of a style into one file, with a pause between them.
void writePreview(String name, File file) {
  const gap = 1.2;
  final style = styles[name]!;
  final parts = [for (final cue in Cue.values) render(style, cueNotes[cue]!)];
  final gapSamples = (gap * sampleRate).round();
  final total = parts.fold(0, (sum, part) => sum + part.length + gapSamples);
  final preview = Float64List(total);
  var offset = 0;
  for (final part in parts) {
    preview.setAll(offset, part);
    offset += part.length + gapSamples;
  }
  file.writeAsBytesSync(wav(preview));
}

void main(List<String> args) {
  if (args.isEmpty) {
    for (final name in styles.keys) {
      writeStyle(name, Directory('assets/sounds/$name'));
    }
    stdout.writeln('Wrote the tones of every style to assets/sounds/.');
  } else if (args.length == 1 && args.first == '--samples') {
    for (final name in styles.keys) {
      writeStyle(name, Directory('build/tone_samples/$name'));
      writePreview(name, File('build/tone_samples/${name}_preview.wav'));
    }
    stdout.writeln('Wrote samples to build/tone_samples/.');
  } else {
    stderr.writeln('Usage: dart run tool/generate_tones.dart [--samples]');
    exitCode = 64;
  }
}
