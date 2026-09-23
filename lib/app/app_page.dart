import 'package:flutter/material.dart';

import '../breathing/breathing_screen.dart';

/// The pages that the sidebar offers. New modes (for example the
/// forced-expiration technique) become a new page here.
enum AppPage { breathing }

extension AppPageDetails on AppPage {
  String get label => switch (this) {
    AppPage.breathing => 'Breathing',
  };

  IconData get icon => switch (this) {
    AppPage.breathing => Icons.self_improvement_rounded,
  };

  Widget buildBody() => switch (this) {
    AppPage.breathing => const BreathingScreen(),
  };
}
