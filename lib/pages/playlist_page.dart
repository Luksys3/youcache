import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/models/playlist.dart';
import 'package:youcache/models/song.dart';
import 'package:youcache/services/songs_service.dart';
import 'package:youcache/widgets/layout/layout.dart';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;

  PlaylistPage({required this.playlist});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool _loaded = false;
  List<Song> _songs = [];

  _load() async {
    final songs = await context.read<SongsService>().all(widget.playlist.id);
    if (mounted) {
      setState(() {
        _loaded = true;
        _songs = songs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      _load();
    }

    return Layout(
      title: widget.playlist.name,
      showBackButton: true,
      child: Container(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: ListView.separated(
            separatorBuilder: (_, __) => Divider(),
            itemCount: _songs.length,
            itemBuilder: (BuildContext context, int index) {
              final song = _songs[index];
              final imageUrl = song.imageUrl;
              return ListTile(
                title: Text(song.name),
                subtitle: Text(song.ownerChannelTitle ?? '-'),
                leading: imageUrl == null
                    ? null
                    : Container(child: Image.network(imageUrl)),
              );
            },
          ),
        ),
      ),
    );
  }
}
