import 'package:flutter/material.dart';
import 'package:notes_app/screens/notes_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String notes = '/notes';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      notes: (context) => const NotesScreen(),
    };
  }
}
