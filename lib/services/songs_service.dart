import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:youcache/enums/snack_bar_type_enum.dart';
import 'package:youcache/helpers/showSnackBar.dart';
import 'package:youcache/models/song.dart';
import 'package:youcache/notifiers/playlists_notifier.dart';
import 'package:youcache/services/database_service.dart';
import 'package:youcache/services/fetch_service.dart';
import 'package:youcache/.env.dart' as ENV;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongsService with ChangeNotifier {
  late DatabaseService _database;
  late FetchService _fetchService;
  late PlaylistsNotifier _playlistsNotifier;
  final BuildContext _context;

  SongsService(
    BuildContext context,
  ) : _context = context;

  init({
    required DatabaseService database,
    required FetchService fetchService,
    required PlaylistsNotifier playlistsNotifier,
  }) {
    _database = database;
    _fetchService = fetchService;
    _playlistsNotifier = playlistsNotifier;
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
    showSnackBar(
      _context,
      'Started fetching playlist songs...',
    );

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
              imageUrl: song['snippet']['thumbnails']['medium'] == null
                  ? null
                  : song['snippet']['thumbnails']['medium']['url'],
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

      final downloadSuccess = await _downloadSong(song);
      if (!downloadSuccess) {
        continue;
      }

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

        // Refresh playlist list
        _playlistsNotifier.load();
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

  Future<bool> _downloadSong(Song song) async {
    try {
      final yt = YoutubeExplode();

      final video = await yt.videos.get(song.videoId);
      final manifest = await yt.videos.streamsClient.getManifest(song.videoId);

      final streamInfo = manifest.audioOnly.withHighestBitrate();

      final streams = yt.videos.streamsClient.get(streamInfo);

      final songsDirectory =
          Directory(await getSongsDirectoryPath(song.playlistId));
      if (!songsDirectory.existsSync()) {
        songsDirectory.createSync();
      }

      final file = File(await getSongFilePath(song));
      final fileStream = file.openWrite();

      await streams.pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();

      song.downloaded = true;
      song.duration = video.duration;
    } catch (_) {
      showSnackBar(
        _context,
        'Failed to download song "${song.name}". ${error.toString()}',
        type: SnackBarTypeEnum.ERROR,
      );
      return false;
    }

    return true;
  }

  Future<String> getSongsDirectoryPath(String playlistId) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${playlistId.replaceAll('/', '')}';
  }

  Future<String> getSongFilePath(Song song) async {
    return '${await getSongsDirectoryPath(song.playlistId)}/${song.id.replaceAll('/', '')}.mp3';
  }
}
