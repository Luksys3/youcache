import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:youcache/enums/snack_bar_type_enum.dart';
import 'package:youcache/helpers/showSnackBar.dart';
import 'package:youcache/models/song.dart';
import 'package:youcache/services/database_service.dart';
import 'package:youcache/services/fetch_service.dart';
import 'package:youcache/.env.dart' as ENV;

class SongsService with ChangeNotifier {
  late DatabaseService _database;
  late FetchService _fetchService;
  final BuildContext _context;

  SongsService(
    BuildContext context,
  ) : _context = context;

  init({
    required DatabaseService database,
    required FetchService fetchService,
  }) {
    _database = database;
    _fetchService = fetchService;
  }

  Future<List<Song>> all(String playlistId) async {
    final db = await _database.database;

    try {
      final List<Map<String, dynamic>> rows = await db.query(
        'songs',
        where: "playlistId = ?",
        whereArgs: [playlistId],
      );

      final reversed = List.from(rows.reversed);
      return List.generate(reversed.length, (index) {
        return Song.fromJson(reversed[index]);
      });
    } on DatabaseException {
      showSnackBar(
        _context,
        'Failed to get songs.',
        type: SnackBarTypeEnum.ERROR,
      );
      return [];
    }
  }

  Future<bool> create(Song song) async {
    final db = await _database.database;

    try {
      await db.insert('songs', song.toMap());
      return true;
    } on DatabaseException {
      showSnackBar(
        _context,
        'Failed to insert song "${song.name}".',
        type: SnackBarTypeEnum.ERROR,
      );
      return false;
    }
  }

  Future<bool> createFromApi(String playlistId) async {
    String? nextPageToken;
    List<Song> songs = [];

    try {
      do {
        final response = await _fetchService.get(
          url: 'https://youtube.googleapis.com/youtube/v3/playlistItems',
          query: {
            'key': ENV.YOUTUBE_API_KEY,
            'part': 'snippet,status',
            'maxResults': 50,
            'playlistId': playlistId,
            'pageToken': nextPageToken,
          },
        );

        if (response == null) {
          showSnackBar(
            _context,
            'Error occurred while fetching songs.',
            type: SnackBarTypeEnum.ERROR,
          );
          return false;
        }

        final Map<String, dynamic> body = jsonDecode(response.body);
        nextPageToken = body['nextPageToken'];

        final songsRaw = body['items'];
        songs.addAll(
          List.generate(songsRaw.length, (index) {
            final Map<String, dynamic> song = songsRaw[index];
            return Song(
              id: song['id'],
              playlistId: playlistId,
              videoId: song['snippet']['resourceId']['videoId'],
              name: song['snippet']['title'],
              imageUrl: song['snippet']['thumbnails']['default'] == null
                  ? null
                  : song['snippet']['thumbnails']['default']['url'],
              status: song['status']['privacyStatus'],
              ownerChannelTitle: song['snippet']['videoOwnerChannelTitle'],
              downloaded: false,
            );
          }),
        );
      } while (nextPageToken != null);
    } on DatabaseException {
      showSnackBar(
        _context,
        'Error occurred while fetching songs.',
        type: SnackBarTypeEnum.ERROR,
      );
      return false;
    }

    final Map<String, Song> existingSongs = Map.fromIterable(
      await all(playlistId),
      key: (song) => song.id,
      value: (song) => song,
    );

    final db = await _database.database;
    int newSongsCount = 0;
    for (int index = 0; index < songs.length; index++) {
      final song = songs[index];
      if (existingSongs.containsKey(song.id)) {
        continue;
      }

      // TODO: download song

      final success = await create(songs[index]);
      if (success) {
        db.rawUpdate(
          """
            UPDATE playlists
            SET downloadedItemCount = downloadedItemCount + 1
            WHERE id = ?
          """,
          [playlistId],
        );
        newSongsCount++;
      }
    }

    showSnackBar(
      _context,
      newSongsCount > 0
          ? 'Successfully fetched $newSongsCount new song${newSongsCount > 1 ? 's' : ''}!'
          : 'Playlist is already up to date.',
    );

    return true;
  }
}
