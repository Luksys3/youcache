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

  _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    _database = await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      version: 7,
      onCreate: (db, version) {
        return db.execute("""
          CREATE TABLE playlists(
            id TEXT PRIMARY KEY,
            name TEXT,
            imageUrl TEXT,
            itemCount INTEGER,
            downloadedItemCount INTEGER
          ),
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Migrating ${oldVersion.toString()} ${newVersion.toString()}');
        await db.execute("DROP TABLE playlists;");

        return db.execute("""
          CREATE TABLE playlists (
            id TEXT PRIMARY KEY,
            name TEXT,
            imageUrl TEXT,
            itemCount INTEGER,
            downloadedItemCount INTEGER
          );
        """);
      },
    );
  }
}
