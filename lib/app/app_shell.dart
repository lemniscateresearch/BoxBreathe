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
    drawer: NavigationDrawer(
      selectedIndex: _pages.indexOf(_page),
      onDestinationSelected: (index) {
        setState(() => _page = _pages[index]);
        Navigator.of(context).pop();
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Text(
            'BoxBreathe',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final page in _pages)
          NavigationDrawerDestination(
            icon: Icon(page.icon),
            label: Text(page.label),
          ),
      ],
    ),
    body: _page.buildBody(),
  );
}
