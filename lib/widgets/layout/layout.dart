import 'package:flutter/material.dart';
import 'package:youcache/constants/primary_swatch.dart';
import 'package:provider/provider.dart';
import 'package:youcache/enums/route_enum.dart';
import 'package:youcache/notifiers/route_notifier.dart';

class Layout extends StatelessWidget {
  final String title;
  final Widget child;

  Layout({
    required this.title,
    required this.child,
  });

  int getCurrentIndex(RouteNotifier route) {
    if (route.isActive(RouteEnum.PLAYER)) {
      return 0;
    } else if (route.isActive(RouteEnum.PLAYLISTS)) {
      return 1;
    } else if (route.isActive(RouteEnum.SETTINGS)) {
      return 2;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final route = context.read<RouteNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        centerTitle: true,
        backgroundColor: PRIMARY_SWATCH[700],
      ),
      backgroundColor: Color(0xff282828),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff131313),
        selectedItemColor: PRIMARY_SWATCH[600],
        currentIndex: getCurrentIndex(route),
        onTap: (int index) {
          switch (index) {
            case 0:
              route.change(RouteEnum.PLAYER);
              return;
            case 1:
              route.change(RouteEnum.PLAYLISTS);
              return;
            case 2:
              route.change(RouteEnum.SETTINGS);
              return;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill_rounded),
            label: 'Player',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music_rounded),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
      body: child,
    );
  }
}
