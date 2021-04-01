import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcache/constants/primary_swatch.dart';
import 'package:youcache/notifiers/route_notifier.dart';
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
          ChangeNotifierProvider(create: (_) => RouteNotifier()),
        ],
        child: AppNavigator(),
      ),
    );
  }
}
