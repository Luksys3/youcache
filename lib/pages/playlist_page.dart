import 'package:flutter/material.dart';
import 'package:youcache/models/playlist.dart';
import 'package:youcache/models/song.dart';
import 'package:youcache/widgets/layout/layout.dart';

class PlaylistPage extends StatelessWidget {
  final Playlist playlist;

  PlaylistPage({required this.playlist});

  @override
  Widget build(BuildContext context) {
    List<Song> songs = [];

    return Layout(
      title: playlist.name,
      showBackButton: true,
      child: Container(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: ListView.separated(
            separatorBuilder: (_, __) => Divider(),
            itemCount: songs.length,
            itemBuilder: (BuildContext context, int index) {
              Song song = songs[index];
              return ListTile(
                title: Text(song.name),
                subtitle: Text(song.length),
                leading: Container(child: Image.network(playlist.imageUrl)),
              );
            },
          ),
        ),
      ),
    );
  }
}
