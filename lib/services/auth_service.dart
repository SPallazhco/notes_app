import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_routes.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String?> registerUser(String email, String password) async {
    try {
      final data = {"email": email, "password": password, "role": "USER"};
      final response = await _apiService.post(ApiRoutes.register, data);
      return response["message"] ?? "Registro exitoso";
    } catch (error) {
      return error.toString();
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await _apiService.post(ApiRoutes.login, {
        "email": email,
        "password": password,
      });

      final String accessToken = response["accessToken"];
      final String refreshToken = response["refreshToken"];

      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        await _saveTokens(accessToken, refreshToken);
        return true; // Login exitoso
      }
      return false;
    } on DioException catch (e) {
      print("Error de login: ${e.response?.data}");
      return false;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refreshToken");
  }
}
