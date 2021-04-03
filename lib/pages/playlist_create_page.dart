import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/enums/snack_bar_type_enum.dart';
import 'package:youcache/helpers/showSnackBar.dart';
import 'package:youcache/notifiers/playlists_notifier.dart';
import 'package:youcache/notifiers/route_notifier.dart';
import 'package:youcache/services/fetch_service.dart';
import 'package:youcache/services/playlists_service.dart';
import 'package:youcache/widgets/field.dart';
import 'package:youcache/widgets/layout/layout.dart';

class PlaylistCreatePage extends StatefulWidget {
  @override
  _PlaylistCreatePageState createState() => _PlaylistCreatePageState();
}

class _PlaylistCreatePageState extends State<PlaylistCreatePage> {
  Map<String, String?> _state = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onSaved(String? value, String name) {
    setState(() {
      _state[name] = value;
    });
  }

  String? parsePlaylistId(String link) {
    final split = link.split(RegExp(r'(\?)|(&)'));
    for (int index = 0; index < split.length; index++) {
      final parameter = split[index];
      if (parameter.startsWith('list=')) {
        return parameter.replaceFirst('list=', '');
      }
    }
  }

  void _submit({
    required BuildContext context,
    required FetchService fetch,
    required PlaylistsNotifier playlists,
    required PlaylistsService playlistsService,
    required RouteNotifier route,
  }) async {
    final state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    state.save();

    final playlistId = parsePlaylistId(_state['link']!);
    if (playlistId == null) {
      showSnackBar(
        context,
        'Invalid playlist link provided.',
        type: SnackBarTypeEnum.ERROR,
      );
      return;
    }

    final response = await playlistsService.createFromApi(playlistId);
    if (response) {
      showSnackBar(
        context,
        'Playlist has been added successfully!',
      );
      route.back();
    }
  }

  _buildLinkField() {
    return Field(
      label: 'Playlist YouTube link',
      helperText: 'Playlist must be set to be accessible via provided link.',
      name: 'link',
      onSaved: _onSaved,
      validator: (value) {
        if (value.isEmpty) {
          return 'This field is required.';
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fetch = context.read<FetchService>();
    final playlists = context.read<PlaylistsNotifier>();
    final playlistsService = context.read<PlaylistsService>();
    final route = context.read<RouteNotifier>();

    return Layout(
      title: 'Add new Playlist',
      formPage: true,
      onSave: () => _submit(
        context: context,
        fetch: fetch,
        playlists: playlists,
        playlistsService: playlistsService,
        route: route,
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLinkField(),
            ],
          ),
        ),
      ),
    );
  }
}
