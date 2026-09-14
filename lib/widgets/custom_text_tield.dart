import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TrimEmailWhitespaceFormatter extends TextInputFormatter {
  const _TrimEmailWhitespaceFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final trimmedText = newValue.text.trim();
    if (trimmedText == newValue.text) {
      return newValue;
    }

    final leadingWhitespaceCount =
        newValue.text.length - newValue.text.trimLeft().length;
    final cursorOffset =
        (newValue.selection.extentOffset - leadingWhitespaceCount)
            .clamp(0, trimmedText.length)
            .toInt();

    return TextEditingValue(
      text: trimmedText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String labelText;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isEmail;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.icon,
    required this.labelText,
    this.controller,
    this.isPassword = false,
    this.isEmail = false,
    this.autofillHints,
    this.textInputAction,
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
      keyboardType: widget.isEmail ? TextInputType.emailAddress : null,
      autofillHints: widget.autofillHints ??
          (widget.isEmail ? const [AutofillHints.email] : null),
      textInputAction: widget.textInputAction,
      autocorrect: !widget.isEmail && !widget.isPassword,
      enableSuggestions: !widget.isEmail && !widget.isPassword,
      textCapitalization: TextCapitalization.none,
      inputFormatters:
          widget.isEmail ? const [_TrimEmailWhitespaceFormatter()] : null,
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
