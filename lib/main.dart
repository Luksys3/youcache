import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/constants/primary_swatch.dart';
import 'package:youcache/notifiers/playing_notifier.dart';
import 'package:youcache/notifiers/playlists_notifier.dart';
import 'package:youcache/notifiers/route_notifier.dart';
import 'package:youcache/services/database_service.dart';
import 'package:youcache/services/fetch_service.dart';
import 'package:youcache/services/playlists_service.dart';
import 'package:youcache/services/songs_service.dart';
import 'package:youcache/widgets/app_navigator.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouCache',
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        brightness: Brightness.dark,
        accentColor: Color(PRIMARY_COLOR),
        primarySwatch: MaterialColor(
          PRIMARY_COLOR,
          PRIMARY_SWATCH,
        ),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => FetchService(context),
          ),
          ChangeNotifierProvider(
            create: (context) => PlaylistsService(context),
          ),
          ChangeNotifierProvider(
            create: (context) => SongsService(context),
          ),
          ChangeNotifierProvider(
            create: (_) => DatabaseService(),
          ),
          ChangeNotifierProvider(
            create: (_) => RouteNotifier(),
          ),
          ChangeNotifierProvider(
            create: (_) => PlayingNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => PlaylistsNotifier(context),
          ),
        ],
        builder: (BuildContext context, Widget? _) {
          final database = context.read<DatabaseService>();
          final fetchService = context.read<FetchService>();
          final playlistsNotifier = context.read<PlaylistsNotifier>();
          final playlistsService = context.read<PlaylistsService>();
          final songsService = context.read<SongsService>();

          playlistsService.init(
            database: database,
            fetchService: fetchService,
            songsService: songsService,
          );
          songsService.init(
            database: database,
            fetchService: fetchService,
            playlistsNotifier: playlistsNotifier,
          );
          playlistsNotifier.init(playlistsService: playlistsService);

          return AudioServiceWidget(child: AppNavigator());
        },
      ),
    );
  }
}
