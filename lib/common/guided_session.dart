import 'package:flutter/foundation.dart';

import 'session_status.dart';

/// A session that guides the user through timed steps. Other objects,
/// such as the session music, listen to its status.
abstract interface class GuidedSession implements Listenable {
  SessionStatus get status;
}
