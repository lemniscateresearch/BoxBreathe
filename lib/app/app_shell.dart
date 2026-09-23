import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_page.dart';

/// Hosts the pages that the sidebar offers, with the breathing screen
/// as the default page. The drawer stays above the page body and keeps
/// its state when the user switches pages.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppPage _page = AppPage.breathing;

  static const _pages = AppPage.values;

  @override
  Widget build(BuildContext context) => Scaffold(
    // A plain drawer with list tiles, not a NavigationDrawer: its
    // destinations have a fixed height and overflow with large text.
    drawer: Drawer(
      width: _drawerWidth(context),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                'BoxBreathe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final (index, page) in _pages.indexed) ...[
              if (index > 0 && _pages[index - 1].isExercise && !page.isExercise)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
              _DrawerDestination(
                page: page,
                selected: page == _page,
                onTap: () {
                  setState(() => _page = page);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    ),
    body: _page.buildBody(),
  );

  /// The normal drawer width, made wider for large text so that long
  /// labels do not break in the middle of a word. Material keeps at
  /// least 56 px of the page visible next to the drawer.
  static double _drawerWidth(BuildContext context) {
    const normalWidth = 304.0;
    final scaled = MediaQuery.textScalerOf(context).scale(normalWidth);
    final maxWidth = MediaQuery.sizeOf(context).width - 56;
    return scaled.clamp(normalWidth, math.max(normalWidth, maxWidth));
  }
}

/// One page in the sidebar, styled like a Material 3 drawer destination.
/// The label wraps and the tile grows when the text is large.
class _DrawerDestination extends StatelessWidget {
  const _DrawerDestination({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final AppPage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ListTile(
      leading: Icon(page.icon),
      title: Text(page.label),
      selected: selected,
      onTap: onTap,
      minTileHeight: 56,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      // The radius equals half the normal height, so a one-line tile is
      // a pill, and a taller tile keeps rounded corners.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: theme.textTheme.labelLarge,
      iconColor: colors.onSurfaceVariant,
      textColor: colors.onSurfaceVariant,
      selectedColor: colors.onSecondaryContainer,
      selectedTileColor: colors.secondaryContainer,
    );
  }
}
