import 'package:flutter/material.dart';
import 'package:youcache/models/playlist.dart';
import 'package:youcache/services/playlists_service.dart';

class PlaylistsNotifier with ChangeNotifier {
  List<Playlist> playlists = [];
  late PlaylistsService _playlistsService;
  final BuildContext _context;

  PlaylistsNotifier(
    BuildContext context,
  ) : _context = context;

  init({
    required PlaylistsService playlistsService,
  }) {
    _playlistsService = playlistsService;
  }

  Future<void> load() async {
    playlists = await _playlistsService.all();
    notifyListeners();
  }

  Future<bool> create(Playlist playlist) async {
    return await _playlistsService.create(playlist);
  }
}
