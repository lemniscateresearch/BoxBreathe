/// Says short spoken cues, such as "Breathe in", so that the user can
/// follow a session without looking at the screen.
abstract interface class CueSpeaker {
  /// Says [text]. A cue that is still playing stops first.
  Future<void> speak(String text);

  /// Stops the cue that is playing, if there is one.
  Future<void> stop();
}
