import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:youcache/widgets/layout/layout.dart';
import 'package:youcache/widgets/player/player.dart';

class PlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Player',
      child: Player(),
    );
  }
}

class MediaLibrary {
  final _items = <MediaItem>[
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "/data/user/0/com.example.youcache/app_flutter/PLdqLrUHHfXcWwRzR2QGeAlFRUS0yilRro/UExkcUxyVUhIZlhjV3dSelIyUUdlQWxGUlVTMHlpbFJyby4xMkVGQjNCMUM1N0RFNEUx.mp3",
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 5739820),
      artUri: Uri.parse(
          "/data/user/0/com.example.youcache/app_flutter/PLdqLrUHHfXcWwRzR2QGeAlFRUS0yilRro/UExkcUxyVUhIZlhjV3dSelIyUUdlQWxGUlVTMHlpbFJyby4xMkVGQjNCMUM1N0RFNEUx.mp3"),
    ),
    MediaItem(
      id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
      album: "Science Friday",
      title: "From Cat Rheology To Operatic Incompetence",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 2856950),
      artUri: Uri.parse(
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    ),
  ];

  List<MediaItem> get items => _items;
}
