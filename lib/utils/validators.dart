class Validators {
  static String normalizeEmail(String? value) => value?.trim() ?? '';

  static String? validateEmail(String? value) {
    final email = normalizeEmail(value);

    if (email.isEmpty) {
      return "Por favor ingresa tu email";
    }
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);
    if (!regex.hasMatch(email)) {
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
