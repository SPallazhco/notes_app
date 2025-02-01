import 'package:flutter/material.dart';
import 'package:notes_app/constants/app_assets.dart';
import 'package:notes_app/services/auth_service.dart';
import 'package:notes_app/utils/validators.dart';
import 'package:notes_app/widgets/custom_button.dart';
import 'package:notes_app/widgets/custom_text_tield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? response = await _authService.registerUser(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response == "User registered successfully") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response!), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Regresar a la pantalla anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response ?? "Error al registrarse"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              AppAssets.mainBody,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Imagen de usuario en círculo
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(AppAssets.userAvatar),
                        ),
                        const SizedBox(height: 20),

                        // Campo de Email
                        CustomTextField(
                            icon: Icons.email,
                            labelText: "Email",
                            controller: emailController,
                            validator: Validators.validateEmail),
                        const SizedBox(height: 15),

                        // Campo de Contraseña
                        CustomTextField(
                          icon: Icons.lock,
                          labelText: "Contraseña",
                          controller: passwordController,
                          isPassword: true,
                          validator: Validators.validatePassword,
                        ),

                        const SizedBox(height: 15),

                        CustomTextField(
                          icon: Icons.lock,
                          labelText: "Confirmar Contraseña",
                          controller: confirmPasswordController,
                          isPassword: true,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                  value, passwordController.text),
                        ),
                        const SizedBox(height: 20),
                        // Botón de Registro
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: "Registrarse",
                            bgColor: Colors.deepPurple,
                            textColor: Colors.white,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : handleRegister,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Botón para volver al login
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "¿Ya tienes una cuenta? Inicia sesión",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
