import 'dart:convert';

class JwtUtils {
  /// Verifica si un token JWT ha expirado
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true; // Token mal formado

      final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int?; // Tiempo de expiración en segundos

      if (exp == null) return true; // No tiene tiempo de expiración

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now >= exp; // Retorna true si el token ya expiró
    } catch (e) {
      return true; // Si hay un error, asumimos que está expirado
    }
  }
}
