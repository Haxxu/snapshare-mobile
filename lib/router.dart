import 'package:flutter/material.dart';
import 'package:snapshare_mobile/screens/screens.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => const AuthScreen());

    case MainScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => const MainScreen());

    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(child: Text('Screen does not exist.')),
        ),
      );
  }
}
