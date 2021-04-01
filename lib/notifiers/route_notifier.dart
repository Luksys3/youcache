import 'package:flutter/material.dart';
import 'package:youcache/enums/route_enum.dart';

class RouteNotifier with ChangeNotifier {
  List<RouteEnum> _path = [RouteEnum.PLAYLISTS];

  List<RouteEnum> get path => _path;
  RouteEnum get active => _path.last;

  void change(RouteEnum route) {
    _path = [route];
    notifyListeners();
  }

  void push(RouteEnum route) {
    _path.add(route);
    notifyListeners();
  }

  bool isActive(RouteEnum route) {
    return _path.contains(route);
  }

  bool back() {
    if (_path.length > 1) {
      _path.removeLast();
      notifyListeners();
      return true;
    }

    return false;
  }
}
