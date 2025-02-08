import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/config/app_routes.dart';
import 'package:notes_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_routes.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiRoutes.baseUrl, // URL base centralizada
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  ));

  Future<dynamic> put(String url, Map<String, dynamic> data,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('refreshToken');

      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters, // Agregar parámetros en la URL
        options: Options(
          headers: {
            if (token != null) "Authorization": "Bearer $token",
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> data,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token =
          url.contains('auth') ? null : prefs.getString('refreshToken');

      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters, // Agregar parámetros en la URL
        options: Options(
          headers: {
            if (token != null) "Authorization": "Bearer $token",
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('refreshToken');

      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            if (token != null) "Authorization": "Bearer $token",
          },
        ),
      );

      return response.data; // Dio ya decodifica JSON automáticamente
    } on DioException catch (e) {
      throw Exception(
          "Error en la solicitud GET: ${e.response?.data ?? e.message}");
    }
  }

  Future<bool> refreshTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        String newRefreshToken = response.data['refreshToken'];
        await prefs.setString('refreshToken', newRefreshToken);

        print('✅ Token actualizado correctamente');
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('⚠️ Refresh token inválido, redirigiendo al login.');

        // 🔹 Mostrar mensaje antes de redirigir
        _showSessionExpiredMessage();

        // 🔹 Redirigir al login
        Future.delayed(const Duration(seconds: 2), () {
          MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        });

        return false;
      } else {
        print('❌ Error en la solicitud de refresh: ${e.message}');
      }
    } catch (e) {
      print('❌ Error inesperado: $e');
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    print('🔑 Tokens eliminados. Sesión cerrada.');
  }

  /// 🔹 Mostrar mensaje cuando la sesión ha caducado
  void _showSessionExpiredMessage() {
    final context = MyApp.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Tu sesión ha caducado. Inicia sesión nuevamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<dynamic> postQueryParameters(String url, queryParameters) async {
    try {
      final response = await _dio.post(url);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleError(DioException e) {
    if (e.response != null) {
      return e.response!.data["message"] ?? "Error desconocido";
    } else {
      return "No se pudo conectar con el servidor";
    }
  }
}
