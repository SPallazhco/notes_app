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
}
