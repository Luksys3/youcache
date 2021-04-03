import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/models/playlist.dart';
import 'package:youcache/models/song.dart';
import 'package:youcache/services/playlists_service.dart';
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
      child: !_loaded
          ? Container()
          : _songs.length == 0
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No songs found.\n\nYou can fetch songs by clicking "Refetch songs" on a playlist.',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (_, __) => Divider(
                    height: 0,
                  ),
                  itemCount: _songs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final song = _songs[index];
                    final imageUrl = song.imageUrl;
                    return ListTile(
                      title: Text(
                        song.name,
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        song.ownerChannelTitle ?? '-',
                        style: TextStyle(fontSize: 12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 6,
                      ),
                      leading: imageUrl == null
                          ? null
                          : Container(child: Image.network(imageUrl)),
                      onTap: () {
                        context
                            .read<PlaylistsService>()
                            .play(widget.playlist, song: song);
                      },
                    );
                  },
                ),
    );
  }
}
