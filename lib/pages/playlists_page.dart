import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/constants/primary_swatch.dart';
import 'package:youcache/enums/route_enum.dart';
import 'package:youcache/notifiers/route_notifier.dart';
import 'package:youcache/widgets/layout/layout.dart';

class PlaylistsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final route = context.read<RouteNotifier>();

    return Layout(
      title: 'Playlists',
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_rounded,
          color: Colors.grey[300],
        ),
        backgroundColor: PRIMARY_SWATCH[700],
        onPressed: () => route.push(RouteEnum.PLAYLIST_CREATE),
      ),
      child: Container(
        child: Text('Hi'),
      ),
    );
  }
}
