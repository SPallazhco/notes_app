class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Por favor ingresa tu email";
    }
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) {
      return "Ingresa un email válido";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Por favor ingresa una contraseña";
    }
    if (value.length < 6) {
      return "La contraseña debe tener al menos 6 caracteres";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Por favor confirma tu contraseña";
    }
    if (value != password) {
      return "Las contraseñas no coinciden";
    }
    return null;
  }
}
