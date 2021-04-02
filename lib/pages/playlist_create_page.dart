import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/enums/snack_bar_type_enum.dart';
import 'package:youcache/helpers/showSnackBar.dart';
import 'package:youcache/services/fetch_service.dart';
import 'package:youcache/widgets/field.dart';
import 'package:youcache/widgets/layout/layout.dart';
import 'package:youcache/.env.dart' as ENV;

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

  void _submit(BuildContext context, FetchService fetch) async {
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

    final response = await fetch.get(
      url: 'https://youtube.googleapis.com/youtube/v3/playlistItems',
      query: {
        'key': ENV.YOUTUBE_API_KEY,
        'part': 'contentDetails',
        'maxResults': 20,
        'playlistId': playlistId
      },
    );

    if (response != null) {
      showSnackBar(
        context,
        'Playlist has been added successfully!',
      );
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetch = context.read<FetchService>();

    return Layout(
      title: 'Add new Playlist',
      formPage: true,
      onSave: () => _submit(context, fetch),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Field(
            label: 'Playlist YouTube link',
            helperText:
                'Playlist must be set to be accessible via provided link.',
            name: 'link',
            autofocus: true,
            onSaved: _onSaved,
            validator: (value) {
              if (value.isEmpty) {
                return 'This field is required.';
              }
            },
          ),
        ),
      ),
    );
  }
}
