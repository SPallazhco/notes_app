import 'package:flutter/material.dart';
import 'package:notes_app/config/app_routes.dart';
import 'package:notes_app/constants/app_assets.dart';
import 'package:notes_app/services/auth_service.dart';
import 'package:notes_app/utils/validators.dart';
import 'package:notes_app/widgets/custom_text_tield.dart';
import 'package:notes_app/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      bool? response = await _authService.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response ? "Bienvenido" : "Error al iniciar sesión"),
          backgroundColor: response ? Colors.green : Colors.red,
        ),
      );

      if (response) {
        Navigator.pushNamed(context, AppRoutes.notes);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al iniciar sesión, verifique sus credenciales"),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception("Error al obtener notas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(AppAssets.userAvatar),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          icon: Icons.email,
                          labelText: "Email",
                          controller: emailController,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          icon: Icons.lock,
                          labelText: "Contraseña",
                          controller: passwordController,
                          isPassword: true,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: "Iniciar Sesión",
                            bgColor: Colors.deepPurple,
                            textColor: Colors.white,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : handleLogin,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text(
                            "¿No tienes cuenta? Regístrate",
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
