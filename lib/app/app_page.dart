import 'package:flutter/material.dart';

import '../breathing/breathing_screen.dart';
import '../clearance/clearance_screen.dart';
import '../settings/settings_screen.dart';

/// The pages that the sidebar offers. A new mode becomes a new page here.
enum AppPage { breathing, clearance, settings }

extension AppPageDetails on AppPage {
  String get label => switch (this) {
    AppPage.breathing => 'Breathing',
    AppPage.clearance => 'Airway clearance',
    AppPage.settings => 'Settings',
  };

  IconData get icon => switch (this) {
    AppPage.breathing => Icons.self_improvement_rounded,
    AppPage.clearance => Icons.air_rounded,
    AppPage.settings => Icons.tune_rounded,
  };

  /// The exercise pages come first in the sidebar. A divider separates
  /// them from the other pages.
  bool get isExercise => switch (this) {
    AppPage.breathing || AppPage.clearance => true,
    AppPage.settings => false,
  };

  Widget buildBody() => switch (this) {
    AppPage.breathing => const BreathingScreen(),
    AppPage.clearance => const ClearanceScreen(),
    AppPage.settings => const SettingsScreen(),
  };
}
