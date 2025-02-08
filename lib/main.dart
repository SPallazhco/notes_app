import 'package:flutter/material.dart';
import 'package:notes_app/config/app_routes.dart';
import 'package:notes_app/services/api_service.dart';
import 'package:notes_app/utils/jwt_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('accessToken');
        final refreshToken = prefs.getString('refreshToken');

        if (accessToken != null && refreshToken != null) {
          if (JwtUtils.isTokenExpired(accessToken)) {
            bool refreshed = await apiService.refreshTokenIfNeeded();
            if (!refreshed) {
              await apiService.logout();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false, // Elimina todas las rutas anteriores
              );
            }
          }
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notes App',
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
