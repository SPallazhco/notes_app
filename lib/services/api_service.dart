import 'package:dio/dio.dart';
import '../constants/api_routes.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiRoutes.baseUrl, // URL base centralizada
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {"Content-Type": "application/json"},
  ));

  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(url, data: data);
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
