import 'package:flutter/material.dart';
import 'package:youcache/widgets/layout/navigation_item.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('e1rg984er87g4er8g'),
            accountEmail: Text('ho'),
          ),
          NavigationItem(
            'Player',
            icon: Icons.play_circle_fill_rounded,
            onTap: () {},
          ),
          NavigationItem(
            'Playlists',
            icon: Icons.queue_music_rounded,
            onTap: () {},
          ),
          NavigationItem(
            'Create new Playlist',
            icon: Icons.playlist_add_rounded,
            onTap: () {},
          ),
          NavigationItem(
            'Settings',
            icon: Icons.settings_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
