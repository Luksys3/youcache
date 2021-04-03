import 'package:flutter/material.dart';
import 'package:youcache/models/song.dart';

class PlayingNotifier with ChangeNotifier {
  Song? song;

  Future<void> setPlaying(Song? song) async {
    this.song = song;
    notifyListeners();
  }
}
