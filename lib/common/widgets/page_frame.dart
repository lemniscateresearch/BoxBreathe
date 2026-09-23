import 'package:flutter/material.dart';

/// The frame of every page: a centered, scrollable column with a maximum
/// width, and a menu button that opens the sidebar.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
              child: child,
            ),
          ),
        ),
        // Menu button that opens the sidebar. It sits above the content
        // in the top-left corner and stays clear of the centered column.
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Open navigation',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    ),
  );
}
