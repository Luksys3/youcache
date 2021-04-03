import 'package:flutter/material.dart';
import 'package:youcache/enums/route_enum.dart';

class RouteNotifier with ChangeNotifier {
  List<RouteEnum> _path = [RouteEnum.PLAYLISTS];
  Map<String, dynamic> _arguments = {};

  List<RouteEnum> get path => _path;
  Map<String, dynamic> get arguments => _arguments;
  RouteEnum get active => _path.last;

  void change(
    RouteEnum route, {
    Map<String, dynamic>? arguments,
  }) {
    _path = [route];
    _arguments = arguments == null ? {} : arguments;
    notifyListeners();
  }

  void push(
    RouteEnum route, {
    Map<String, dynamic>? arguments,
  }) {
    _path.add(route);
    _arguments = arguments == null ? {} : arguments;
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
