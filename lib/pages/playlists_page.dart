import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/constants/primary_swatch.dart';
import 'package:youcache/enums/route_enum.dart';
import 'package:youcache/helpers/showSnackBar.dart';
import 'package:youcache/models/playlist.dart';
import 'package:youcache/notifiers/playlists_notifier.dart';
import 'package:youcache/notifiers/route_notifier.dart';
import 'package:youcache/services/playlists_service.dart';
import 'package:youcache/widgets/layout/layout.dart';

class PlaylistsPage extends StatelessWidget {
  void _startRefetch({
    required BuildContext context,
    required String playlistId,
  }) {
    print('Starting refetch for playlist "$playlistId".');
  }

  void _showDeleteDialog({
    required BuildContext appContext,
    required String playlistId,
  }) {
    showDialog(
      context: appContext,
      builder: (context) => AlertDialog(
        title: Text("Warning!"),
        content: Text("Are sure you want to this playlist delete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final PlaylistsService playlistsService =
                  appContext.read<PlaylistsService>();

              final success = await playlistsService.delete(playlistId);
              if (success) {
                showSnackBar(
                  context,
                  'Playlist has been successfully deleted!',
                );

                await appContext.read<PlaylistsNotifier>().load();
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Color(0xffDC2626)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<PlaylistsNotifier>().load();

    return Layout(
      title: 'Playlists',
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_rounded,
          color: Colors.grey[300],
        ),
        backgroundColor: PRIMARY_SWATCH[700],
        onPressed: () {
          context.read<RouteNotifier>().push(RouteEnum.PLAYLIST_CREATE);
        },
      ),
      child: Container(
        child: Consumer<PlaylistsNotifier>(
          builder: (
            BuildContext context,
            PlaylistsNotifier playlists,
            Widget? _,
          ) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: ListView.separated(
                separatorBuilder: (_, __) => Divider(),
                itemCount: playlists.playlists.length,
                itemBuilder: (BuildContext context, int index) {
                  Playlist playlist = playlists.playlists[index];
                  return ListTile(
                    title: Text(playlist.name),
                    subtitle: Text(
                      '${playlist.downloadedItemCount} / ${playlist.itemCount}',
                    ),
                    leading: Container(child: Image.network(playlist.imageUrl)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.play_arrow_rounded,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                        PopupMenuButton<String>(
                          onSelected: (String result) {
                            switch (result) {
                              case 'refetch':
                                _startRefetch(
                                  context: context,
                                  playlistId: playlist.id,
                                );
                                break;

                              case 'delete':
                                _showDeleteDialog(
                                  appContext: context,
                                  playlistId: playlist.id,
                                );
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'refetch',
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh_rounded),
                                    SizedBox(width: 16),
                                    Text('Refetch songs'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_rounded),
                                    SizedBox(width: 16),
                                    Text('Delete playlist'),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
