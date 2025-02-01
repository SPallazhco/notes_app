import 'package:flutter/material.dart';
import 'package:notes_app/config/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      initialRoute: AppRoutes.login,
      routes: AppRoutes.getRoutes(),
    );
  }
}
