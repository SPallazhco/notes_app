import 'package:flutter/material.dart';
import 'package:notes_app/config/app_routes.dart';
import 'package:notes_app/constants/app_assets.dart';
import 'package:notes_app/widgets/custom_button.dart';
import 'package:notes_app/widgets/custom_text_tield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con imagen
          Image.asset(
            AppAssets.mainBody,
            fit: BoxFit.cover,
          ),

          // Contenido centrado
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagen de usuario
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      AppAssets.userAvatar,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input de usuario
                  CustomTextField(
                    icon: Icons.person,
                    labelText: "Usuario",
                    controller: userController,
                  ),
                  const SizedBox(height: 10),

                  // Input de contraseña
                  CustomTextField(
                    icon: Icons.lock,
                    labelText: "Contraseña",
                    isPassword: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 20),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        text: "Ingreso",
                        bgColor: Colors.deepPurple,
                        textColor: Colors.white,
                        onPressed: () {
                          String userInput = userController.text;
                          String passwordUser = passwordController.text;
                          print("Usuario ingresado: $passwordUser");
                          print("Usuario ingresado: $userInput");
                        },
                      ),
                      CustomButton(
                        text: "Registro",
                        bgColor: Colors.white,
                        textColor: Colors.deepPurple,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
