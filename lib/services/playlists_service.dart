import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
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
      songsDirectory.deleteSync(recursive: true);

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
      imageUrl: body['items'][0]['snippet']['thumbnails']['default']['url'],
      itemCount: body['items'][0]['contentDetails']['itemCount'],
      downloadedItemCount: 0,
    );
  }
}
