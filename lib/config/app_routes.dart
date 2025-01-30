import 'package:flutter/material.dart';
import 'package:notes_app/screens/login_screen.dart';

class AppRoutes {
  static const String login = "/login";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(child: Text("Ruta no encontrada")),
                ));
    }
  }
}
