import 'package:flutter/material.dart';
import 'package:youcache/widgets/layout/layout.dart';
import 'package:youcache/widgets/player/player.dart';

class PlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'YouCache',
      child: Player(),
    );
  }
}
