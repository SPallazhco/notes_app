class ApiRoutes {
  // static const String baseUrl = "http://10.0.2.2:8080/api";
  static const String baseUrl = "https://login-service-q30o.onrender.com/api";

  // Endpoints de autenticación
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";

  // Endpoints de notas
  static const String getNotes = "$baseUrl/notes";
  static const String createNote = "$baseUrl/notes/create";
  static const String updateNoteStatus = "$baseUrl/notes/update-status";
}
