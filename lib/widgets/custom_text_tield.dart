import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String labelText;
  final TextEditingController? controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.icon,
    required this.labelText,
    this.controller,
    this.isPassword = false,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: Colors.grey),
        labelText: widget.labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: widget.validator, // Permite validaciones personalizadas
    );
  }
}
