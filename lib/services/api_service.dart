import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_routes.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiRoutes.baseUrl, // URL base centralizada
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {"Content-Type": "application/json"},
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
      String? token = prefs.getString('refreshToken');

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
