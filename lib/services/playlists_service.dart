import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:youcache/classes/audio_service_wrapper.dart';
import 'package:youcache/enums/snack_bar_type_enum.dart';
import 'package:youcache/helpers/showSnackBar.dart';
import 'package:youcache/models/playlist.dart';
import 'package:youcache/services/database_service.dart';
import 'package:youcache/services/fetch_service.dart';
import 'package:youcache/.env.dart' as ENV;
import 'package:youcache/services/songs_service.dart';

class PlaylistsService with ChangeNotifier {
  late DatabaseService _database;
  late FetchService _fetchService;
  late SongsService _songsService;
  final BuildContext _context;

  PlaylistsService(
    BuildContext context,
  ) : _context = context;

  init({
    required DatabaseService database,
    required FetchService fetchService,
    required SongsService songsService,
  }) {
    _database = database;
    _fetchService = fetchService;
    _songsService = songsService;
  }

  Future<void> play(Playlist playlist) async {
    final songs = await _songsService.all(playlist.id);

    List<MediaItem> queue = [];
    for (int index = 0; index < songs.length; index++) {
      final song = songs[index];
      final pathToSong = await _songsService.getSongFilePath(song);
      // print('pathToSong $index $pathToSong');
      queue.add(
        MediaItem(
          // This can be any unique id, but we use the audio URL for convenience.
          id: pathToSong,
          album: playlist.name,
          title: song.name,
          artist: song.ownerChannelTitle,
          duration: song.duration,
          artUri: song.imageUrl == null ? null : Uri.parse(song.imageUrl!),
        ),
      );
    }

    await AudioServiceWrapper.start();

    await AudioService.updateQueue(queue);
    await AudioService.play();
  }

  Future<List<Playlist>> all() async {
    final db = await _database.database;

    try {
      final List<Map<String, dynamic>> playlistsRaw =
          await db.query('playlists');

      return List.generate(playlistsRaw.length, (index) {
        return Playlist.fromJson(playlistsRaw[index]);
      });
    } on DatabaseException {
      showSnackBar(
        _context,
        'Failed to get playlists.',
        type: SnackBarTypeEnum.ERROR,
      );
      return [];
    }
  }

  Future<bool> delete(String playlistId) async {
    final db = await _database.database;

    try {
      final songsDirectory =
          Directory(await _songsService.getSongsDirectoryPath(playlistId));
      if (songsDirectory.existsSync()) {
        songsDirectory.deleteSync(recursive: true);
      }

      await db.delete(
        'playlists',
        where: "id = ?",
        whereArgs: [playlistId],
      );
      return true;
    } on DatabaseException {
      showSnackBar(
        _context,
        'Failed to delete playlist.',
        type: SnackBarTypeEnum.ERROR,
      );
      return false;
    }
  }

  Future<bool> create(Playlist playlist) async {
    final db = await _database.database;

    try {
      final existingPlaylist = await db.query(
        'playlists',
        limit: 1,
        where: "id = ?",
        whereArgs: [playlist.id],
      );
      if (existingPlaylist.length > 0) {
        showSnackBar(
          _context,
          'This playlist already exists.',
          type: SnackBarTypeEnum.ERROR,
        );
        return false;
      }

      await db.insert('playlists', playlist.toMap());
      return true;
    } on DatabaseException {
      showSnackBar(
        _context,
        'Failed to add playlist to local storage.',
        type: SnackBarTypeEnum.ERROR,
      );
      return false;
    }
  }

  Future<bool> update(Playlist playlist) async {
    final db = await _database.database;

    try {
      await db.update(
        'playlists',
        {'itemCount': playlist.itemCount},
        where: "id = ?",
        whereArgs: [playlist.id],
      );
      return true;
    } on DatabaseException {
      showSnackBar(
        _context,
        'Failed to update playlist.',
        type: SnackBarTypeEnum.ERROR,
      );
      return false;
    }
  }

  Future<bool> updateFromApi(String playlistId) async {
    final playlist = await _getFromApi(playlistId);
    if (playlist == null) {
      return false;
    }

    return await update(playlist);
  }

  Future<bool> createFromApi(String playlistId) async {
    final playlist = await _getFromApi(playlistId);
    if (playlist == null) {
      return false;
    }

    return await create(playlist);
  }

  Future<Playlist?> _getFromApi(String playlistId) async {
    final response = await _fetchService.get(
      url: 'https://youtube.googleapis.com/youtube/v3/playlists',
      query: {
        'key': ENV.YOUTUBE_API_KEY,
        'part': 'snippet,contentDetails',
        'id': playlistId,
      },
    );

    if (response == null) {
      return null;
    }

    final body = jsonDecode(response.body);
    if (body['pageInfo']['totalResults'] == 0) {
      showSnackBar(
        _context,
        'Playlist was not found or it cannot be accessed via link.',
        type: SnackBarTypeEnum.ERROR,
      );
      return null;
    }

    return Playlist(
      id: playlistId,
      name: body['items'][0]['snippet']['title'],
      imageUrl: body['items'][0]['snippet']['thumbnails']['medium']['url'],
      itemCount: body['items'][0]['contentDetails']['itemCount'],
      downloadedItemCount: 0,
    );
  }
}
