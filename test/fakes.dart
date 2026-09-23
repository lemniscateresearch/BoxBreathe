import 'package:box_breathe/common/audio/cue_player.dart';
import 'package:box_breathe/common/audio/session_cue.dart';

/// Records the cues that a session plays.
class FakeCuePlayer implements CuePlayer {
  final cues = <SessionCue>[];
  final words = <String>[];
  var stops = 0;

  @override
  Future<void> play(SessionCue cue, String words) async {
    cues.add(cue);
    this.words.add(words);
  }

  @override
  Future<void> stop() async => stops++;
}
