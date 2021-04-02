import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class DatabaseService extends ChangeNotifier {
  Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      await _initDatabase();
    }

    return _database!;
  }

  _setupDatabase(Database db) async {
    await db.execute("DROP TABLE IF EXISTS playlists;");
    await db.execute("""
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        itemCount INTEGER NOT NULL,
        downloadedItemCount INTEGER NOT NULL
      );
    """);

    await db.execute("DROP TABLE IF EXISTS songs;");
    await db.execute("""
      CREATE TABLE songs (
        id TEXT PRIMARY KEY,
        playlistId TEXT NOT NULL,
        videoId TEXT NOT NULL,
        name TEXT NOT NULL,
        imageUrl TEXT,
        status TEXT NOT NULL,
        ownerChannelTitle TEXT,
        downloaded INTEGER NOT NULL,
        FOREIGN KEY (playlistId)
        REFERENCES playlists (id)
          ON DELETE CASCADE
      );
    """);
  }

  _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    _database = await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      version: 14,
      onConfigure: (db) {
        db.execute("PRAGMA foreign_keys = ON;");
      },
      onCreate: (db, version) {
        _setupDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Migrating ${oldVersion.toString()} ${newVersion.toString()}');
        _setupDatabase(db);
      },
    );
  }
}
