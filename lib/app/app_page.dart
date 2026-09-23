import 'package:flutter/material.dart';

import '../breathing/breathing_screen.dart';
import '../clearance/clearance_screen.dart';

/// The pages that the sidebar offers. A new mode becomes a new page here.
enum AppPage { breathing, clearance }

extension AppPageDetails on AppPage {
  String get label => switch (this) {
    AppPage.breathing => 'Breathing',
    AppPage.clearance => 'Airway clearance',
  };

  IconData get icon => switch (this) {
    AppPage.breathing => Icons.self_improvement_rounded,
    AppPage.clearance => Icons.air_rounded,
  };

  Widget buildBody() => switch (this) {
    AppPage.breathing => const BreathingScreen(),
    AppPage.clearance => const ClearanceScreen(),
  };
}
