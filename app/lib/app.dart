import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';
import 'features/library/playlist_screen.dart';
import 'features/player/mini_player.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => Shell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
            routes: [
              GoRoute(
                path: 'playlist/:id',
                builder: (context, state) =>
                    PlaylistScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
        ]),
      ],
    ),
  ],
);

class Shell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const Shell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayer(),
            NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (i) =>
                  shell.goBranch(i, initialLocation: i == shell.currentIndex),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                NavigationDestination(
                    icon: Icon(Icons.library_music_outlined), label: 'Library'),
              ],
            ),
          ],
        ),
      );
}
