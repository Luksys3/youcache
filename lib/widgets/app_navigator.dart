import 'package:flutter/material.dart';
import 'package:youcache/enums/route_enum.dart';
import 'package:youcache/notifiers/route_notifier.dart';
import 'package:youcache/pages/player_page.dart';
import 'package:youcache/pages/playlists_page.dart';
import 'package:provider/provider.dart';
import 'package:youcache/pages/settings_page.dart';

class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final route = context.watch<RouteNotifier>();

    return WillPopScope(
      onWillPop: () async => !route.back(),
      child: Navigator(
        pages: [
          if (route.isActive(RouteEnum.PLAYER))
            MaterialPage(child: PlayerPage()),
          if (route.isActive(RouteEnum.PLAYLISTS))
            MaterialPage(child: PlaylistsPage()),
          if (route.isActive(RouteEnum.SETTINGS))
            MaterialPage(child: SettingsPage()),
        ],
        onPopPage: (route, result) => route.didPop(result),
      ),
    );
  }
}
