import 'package:flutter/material.dart';
import 'package:youcache/constants/primary_swatch.dart';
import 'package:provider/provider.dart';
import 'package:youcache/enums/route_enum.dart';
import 'package:youcache/notifiers/route_notifier.dart';

class Layout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool formPage;
  final void Function()? onSave;
  final FloatingActionButton? floatingActionButton;

  Layout({
    required this.title,
    required this.child,
    this.formPage = false,
    this.onSave,
    this.floatingActionButton,
  });

  int getCurrentIndex(RouteNotifier route) {
    if (route.isActive(RouteEnum.PLAYER)) {
      return 0;
    } else if (route.isActive(RouteEnum.PLAYLISTS)) {
      return 1;
    } else if (route.isActive(RouteEnum.SETTINGS)) {
      return 2;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final route = context.read<RouteNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: formPage ? null : Text(title),
        elevation: 0,
        centerTitle: true,
        backgroundColor: PRIMARY_SWATCH[700],
        leading: formPage
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                iconSize: 26,
                onPressed: () => route.back(),
              )
            : null,
        actions: [
          if (formPage)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSave,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Text(
                    'SAVE',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Color(0xff282828),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: formPage
          ? null
          : BottomNavigationBar(
              backgroundColor: Color(0xff131313),
              selectedItemColor: PRIMARY_SWATCH[600],
              currentIndex: getCurrentIndex(route),
              onTap: (int index) {
                switch (index) {
                  case 0:
                    route.change(RouteEnum.PLAYER);
                    return;
                  case 1:
                    route.change(RouteEnum.PLAYLISTS);
                    return;
                  case 2:
                    route.change(RouteEnum.SETTINGS);
                    return;
                }
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_circle_fill_rounded),
                  label: 'Player',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.queue_music_rounded),
                  label: 'Playlists',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
      body: child,
    );
  }
}
