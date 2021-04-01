import 'package:flutter/material.dart';
import 'package:youcache/widgets/field.dart';
import 'package:youcache/widgets/layout/layout.dart';

class PlaylistCreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Add new Playlist',
      formPage: true,
      onSave: () {},
      child: Container(
        padding: EdgeInsets.all(20),
        child: Field(
          label: 'Playlist YouTube link',
          name: 'link',
          autofocus: true,
        ),
      ),
    );
  }
}
